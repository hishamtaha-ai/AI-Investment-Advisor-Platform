from __future__ import annotations

import argparse
import json
import logging
import sys
from datetime import datetime
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))

from preprocessing import load_all_data, preprocess_ticker  # noqa: E402
from rnn_model import train_and_evaluate_ticker  # noqa: E402


def make_run_folder(output_root: Path) -> Path:
    output_root.mkdir(parents=True, exist_ok=True)
    base = datetime.now().strftime("run_%Y%m%d_%H%M%S")
    run_folder = output_root / base
    suffix = 1
    while run_folder.exists():
        run_folder = output_root / f"{base}_{suffix:02d}"
        suffix += 1
    run_folder.mkdir(parents=True)
    return run_folder


def setup_logging(run_folder: Path) -> logging.Logger:
    logger = logging.getLogger("rnn_pipeline")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()
    formatter = logging.Formatter("%(asctime)s | %(levelname)s | %(message)s")
    file_handler = logging.FileHandler(run_folder / "run.log", encoding="utf-8")
    file_handler.setFormatter(formatter)
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    logger.addHandler(stream_handler)
    return logger


def main() -> int:
    parser = argparse.ArgumentParser(description="All-tickers RNN pipeline")
    parser.add_argument("--data", default="data/all_cleaned.csv",
                        help="Path to the cleaned data file in the data/ folder")
    parser.add_argument("--output", default="ml/results",
                        help="Output folder; each run gets a new subfolder inside it")
    parser.add_argument("--tickers", default=None,
                        help="Comma-separated ticker names to run; default is all tickers")
    parser.add_argument("--epochs", type=int, default=100)
    parser.add_argument("--min-train", type=int, default=100,
                        help="Skip tickers with fewer training rows than this")
    parser.add_argument("--min-val", type=int, default=20,
                        help="Skip tickers with fewer validation rows than this")
    args = parser.parse_args()

    run_folder = make_run_folder(Path(args.output))
    logger = setup_logging(run_folder)
    logger.info("Run folder: %s", run_folder)
    logger.info("Data file: %s", args.data)

    df = load_all_data(args.data)
    all_tickers = sorted(df["ticker"].unique().tolist())
    if args.tickers:
        wanted = {t.strip() for t in args.tickers.split(",") if t.strip()}
        tickers = [t for t in all_tickers if t in wanted]
        missing = wanted - set(tickers)
        for t in sorted(missing):
            logger.warning("Requested ticker not found in data: %s", t)
    else:
        tickers = all_tickers
    logger.info("Total tickers in data: %d | Tickers to run: %d",
                len(all_tickers), len(tickers))

    results = []
    predictions = []
    skipped = []

    for ticker in tickers:
        try:
            split = preprocess_ticker(df[df["ticker"] == ticker])
        except Exception as exc:  # noqa: BLE001 - keep the run going
            logger.warning("SKIPPED %s during preprocessing: %s", ticker, exc)
            skipped.append({"ticker": ticker, "reason": f"preprocessing: {exc}"})
            continue
        if split.train.empty or split.forecast_input.empty:
            reason = "no train rows or no forecast input"
            logger.warning("SKIPPED %s: %s", ticker, reason)
            skipped.append({"ticker": ticker, "reason": reason})
            continue
        if len(split.train) < args.min_train or len(split.val) < args.min_val:
            reason = (f"too little data: train={len(split.train)}, "
                      f"val={len(split.val)}")
            logger.warning("SKIPPED %s: %s", ticker, reason)
            skipped.append({"ticker": ticker, "reason": reason})
            continue
        try:
            result = train_and_evaluate_ticker(split, epochs=args.epochs)
        except Exception as exc:  # noqa: BLE001 - keep the run going
            logger.warning("SKIPPED %s during training: %s", ticker, exc)
            skipped.append({"ticker": ticker, "reason": f"training: {exc}"})
            continue

        logger.info(
            "%s | train=%d val=%d | baseline MAE=%.3f RMSE=%.3f | "
            "RNN MAE=%.3f RMSE=%.3f (best epoch %d) | forecast=%.2f (%+.2f%%)",
            result.ticker, result.n_train, result.n_val,
            result.baseline_mae, result.baseline_rmse,
            result.rnn_mae, result.rnn_rmse, result.best_epoch,
            result.forecast_price, result.forecast_change_pct,
        )
        results.append(
            {
                "ticker": result.ticker,
                "n_train": result.n_train,
                "n_val": result.n_val,
                "baseline_mae": result.baseline_mae,
                "baseline_rmse": result.baseline_rmse,
                "rnn_mae": result.rnn_mae,
                "rnn_rmse": result.rnn_rmse,
                "best_epoch": result.best_epoch,
                "last_close": result.last_close,
                "forecast_price_40d": result.forecast_price,
                "forecast_change_pct": result.forecast_change_pct,
            }
        )
        for target, pred in zip(result.val_targets, result.val_predictions):
            predictions.append(
                {"ticker": result.ticker, "y_true": float(target), "y_pred": float(pred)}
            )

    results_df = pd.DataFrame(results)
    results_df.to_csv(run_folder / "results.csv", index=False)
    pd.DataFrame(predictions).to_csv(run_folder / "predictions.csv", index=False)

    summary = {
        "run_folder": str(run_folder),
        "timestamp": datetime.now().isoformat(),
        "data_file": args.data,
        "epochs": args.epochs,
        "tickers_total_in_data": len(all_tickers),
        "tickers_trained": len(results),
        "tickers_skipped": len(skipped),
        "skipped": skipped,
        "mean_rnn_mae": float(results_df["rnn_mae"].mean()) if results else None,
        "mean_baseline_mae": float(results_df["baseline_mae"].mean()) if results else None,
        "mean_rnn_rmse": float(results_df["rnn_rmse"].mean()) if results else None,
        "tickers_beating_baseline_mae": int(
            (results_df["rnn_mae"] < results_df["baseline_mae"]).sum()
        ) if results else 0,
    }
    (run_folder / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    logger.info("Done. Trained=%d Skipped=%d. Results in %s",
                len(results), len(skipped), run_folder)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
