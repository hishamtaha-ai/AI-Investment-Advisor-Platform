from __future__ import annotations

import os

os.environ.setdefault("TF_ENABLE_ONEDNN_OPTS", "0")

from dataclasses import dataclass

import numpy as np
import tensorflow as tf
from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.preprocessing import StandardScaler

from preprocessing import FEATURE_COLS, TARGET_COL


@dataclass
class TickerResult:
    ticker: str
    n_train: int
    n_val: int
    baseline_mae: float
    baseline_rmse: float
    rnn_mae: float
    rnn_rmse: float
    best_epoch: int
    last_close: float
    forecast_price: float
    forecast_change_pct: float
    val_predictions: np.ndarray
    val_targets: np.ndarray


def build_rnn() -> tf.keras.Model:
    np.random.seed(42)
    tf.random.set_seed(42)
    tf.keras.utils.set_random_seed(42)
    try:
        tf.config.experimental.enable_op_determinism()
    except Exception:
        pass
    model = tf.keras.Sequential(
        [
            tf.keras.layers.Input(shape=(1, len(FEATURE_COLS))),
            tf.keras.layers.SimpleRNN(32, activation="relu"),
            tf.keras.layers.Dense(16, activation="relu"),
            tf.keras.layers.Dense(1),
        ]
    )
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.005), loss="mae")
    return model


def train_and_evaluate_ticker(split, epochs: int = 100) -> TickerResult:
    """Train one RNN for one ticker split and evaluate on its validation set."""
    train, val, forecast_input = split.train, split.val, split.forecast_input

    x_train = train[FEATURE_COLS].values
    y_train = train[TARGET_COL].values
    x_val = val[FEATURE_COLS].values
    y_val = val[TARGET_COL].values
    x_forecast = forecast_input[FEATURE_COLS].values

    scaler = StandardScaler()
    x_train_scaled = scaler.fit_transform(x_train)
    x_val_scaled = scaler.transform(x_val)
    x_forecast_scaled = scaler.transform(x_forecast)

    x_train_rnn = x_train_scaled.reshape((len(x_train_scaled), 1, len(FEATURE_COLS)))
    x_val_rnn = x_val_scaled.reshape((len(x_val_scaled), 1, len(FEATURE_COLS)))
    x_forecast_rnn = x_forecast_scaled.reshape(
        (len(x_forecast_scaled), 1, len(FEATURE_COLS))
    )

    baseline_preds = val["close"].values
    baseline_mae = float(mean_absolute_error(y_val, baseline_preds))
    baseline_rmse = float(np.sqrt(mean_squared_error(y_val, baseline_preds)))

    model = build_rnn()
    early_stop = tf.keras.callbacks.EarlyStopping(
        monitor="val_loss", patience=100, restore_best_weights=True
    )
    history = model.fit(
        x_train_rnn,
        y_train,
        validation_data=(x_val_rnn, y_val),
        epochs=epochs,
        batch_size=32,
        shuffle=False,
        callbacks=[early_stop],
        verbose=0,
    )

    val_preds = model.predict(x_val_rnn, verbose=0).flatten()
    rnn_mae = float(mean_absolute_error(y_val, val_preds))
    rnn_rmse = float(np.sqrt(mean_squared_error(y_val, val_preds)))
    best_epoch = int(np.argmin(history.history["val_loss"]) + 1)

    forecast_price = float(model.predict(x_forecast_rnn, verbose=0).flatten()[0])
    last_close = float(forecast_input["close"].iloc[0])
    forecast_change_pct = float((forecast_price - last_close) / last_close * 100)

    return TickerResult(
        ticker=split.ticker,
        n_train=len(train),
        n_val=len(val),
        baseline_mae=baseline_mae,
        baseline_rmse=baseline_rmse,
        rnn_mae=rnn_mae,
        rnn_rmse=rnn_rmse,
        best_epoch=best_epoch,
        last_close=last_close,
        forecast_price=forecast_price,
        forecast_change_pct=forecast_change_pct,
        val_predictions=val_preds,
        val_targets=y_val,
    )
