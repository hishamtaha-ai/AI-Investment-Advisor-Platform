from __future__ import annotations

from dataclasses import dataclass

import pandas as pd

HORIZON = 40
FEATURE_COLS = ["close_lag_1", "ma_5"]
TARGET_COL = "target_close_40d"
TRAIN_CUTOFF = "2025-01-01"
VAL_START = "2025-01-01"
VAL_TARGET_END = "2025-12-31"


@dataclass
class TickerSplit:
    ticker: str
    train: pd.DataFrame
    val: pd.DataFrame
    forecast_input: pd.DataFrame
    n_rows: int


def load_all_data(data_path: str) -> pd.DataFrame:
    """Load the cleaned data file from the ``data/`` folder."""
    df = pd.read_csv(data_path)
    df["date"] = pd.to_datetime(df["date"])
    df["close"] = pd.to_numeric(df["close"], errors="coerce")
    df = df.dropna(subset=["date", "close", "ticker"])
    df = df.sort_values(["ticker", "date"]).reset_index(drop=True)
    return df


def preprocess_ticker(ticker_df: pd.DataFrame) -> TickerSplit:
    """Build features, target and the temporal split for one ticker."""
    ticker = str(ticker_df["ticker"].iloc[0])
    history = ticker_df.sort_values("date").reset_index(drop=True).copy()

    history["close_lag_1"] = history["close"].shift(1)
    history["ma_5"] = history["close"].rolling(window=5).mean()
    history["target_close_40d"] = history["close"].shift(-HORIZON)
    history["target_date_40d"] = history["date"].shift(-HORIZON)

    trainable = history.dropna(
        subset=FEATURE_COLS + [TARGET_COL, "target_date_40d"]
    ).copy()

    train = trainable[trainable["target_date_40d"] < TRAIN_CUTOFF].copy()
    val = trainable[
        (trainable["date"] >= VAL_START)
        & (trainable["target_date_40d"] <= VAL_TARGET_END)
    ].copy()

    # Forecast input: last row of 2025 with valid features, even though
    # its 40-session target falls in 2026 and is therefore unknown.
    history_2025 = history[
        (history["date"] <= VAL_TARGET_END)
    ].dropna(subset=FEATURE_COLS)
    forecast_input = (
        history_2025.tail(1).copy() if not history_2025.empty else history.tail(0).copy()
    )

    return TickerSplit(
        ticker=ticker,
        train=train,
        val=val,
        forecast_input=forecast_input,
        n_rows=len(history),
    )
