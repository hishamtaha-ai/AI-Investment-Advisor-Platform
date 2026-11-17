from __future__ import annotations

import copy
from dataclasses import dataclass

import numpy as np
import torch
from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.preprocessing import StandardScaler
from torch import nn

from preprocessing import FEATURE_COLS, TARGET_COL

# Use the GPU when PyTorch can see one, otherwise fall back to CPU.
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

_DEVICE_ANNOUNCED = False


def _announce_device() -> None:
    global _DEVICE_ANNOUNCED
    if _DEVICE_ANNOUNCED:
        return
    _DEVICE_ANNOUNCED = True
    if DEVICE.type == "cuda":
        print(f"Using device: cuda ({torch.cuda.get_device_name(0)})")
    else:
        print("Using device: cpu (no CUDA GPU found)")


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


class RNNModel(nn.Module):
    """SimpleRNN(32, relu) -> Dense(16, relu) -> Dense(1), as in the notebook."""

    def __init__(self, input_size: int) -> None:
        super().__init__()
        self.rnn = nn.RNN(
            input_size=input_size,
            hidden_size=32,
            num_layers=1,
            nonlinearity="relu",
            batch_first=True,
        )
        self.fc1 = nn.Linear(32, 16)
        self.fc2 = nn.Linear(16, 1)
        self.relu = nn.ReLU()
        self._init_weights()

    def _init_weights(self) -> None:
        # Mirror the Keras default initializers of the original model:
        # Glorot uniform kernels, orthogonal recurrent kernel, zero biases.
        nn.init.xavier_uniform_(self.rnn.weight_ih_l0)
        nn.init.orthogonal_(self.rnn.weight_hh_l0)
        nn.init.zeros_(self.rnn.bias_ih_l0)
        nn.init.zeros_(self.rnn.bias_hh_l0)
        nn.init.xavier_uniform_(self.fc1.weight)
        nn.init.zeros_(self.fc1.bias)
        nn.init.xavier_uniform_(self.fc2.weight)
        nn.init.zeros_(self.fc2.bias)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        out, _ = self.rnn(x)
        last_step = out[:, -1, :]
        hidden = self.relu(self.fc1(last_step))
        return self.fc2(hidden).squeeze(-1)


def build_rnn() -> nn.Module:
    np.random.seed(42)
    torch.manual_seed(42)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(42)
    try:
        # warn_only=True: a few CUDA kernels have no deterministic version
        # and would raise instead of train; on CPU this changes nothing.
        torch.use_deterministic_algorithms(True, warn_only=True)
    except Exception:
        try:
            torch.use_deterministic_algorithms(True)
        except Exception:
            pass
    if DEVICE.type == "cuda":
        torch.backends.cudnn.deterministic = True
        torch.backends.cudnn.benchmark = False
    return RNNModel(input_size=len(FEATURE_COLS)).to(DEVICE)


def _to_tensor(values: np.ndarray) -> torch.Tensor:
    arr = np.asarray(values, dtype=np.float32)
    tensor = torch.from_numpy(arr).reshape((len(arr), 1, len(FEATURE_COLS)))
    return tensor.to(DEVICE)


def _target_tensor(values: np.ndarray) -> torch.Tensor:
    return torch.from_numpy(np.asarray(values, dtype=np.float32)).to(DEVICE)


def train_and_evaluate_ticker(split, epochs: int = 100) -> TickerResult:
    """Train one RNN for one ticker split and evaluate on its validation set."""
    _announce_device()
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

    x_train_t = _to_tensor(x_train_scaled)
    y_train_t = _target_tensor(y_train)
    x_val_t = _to_tensor(x_val_scaled)
    y_val_t = _target_tensor(y_val)
    x_forecast_t = _to_tensor(x_forecast_scaled)

    baseline_preds = val["close"].values
    baseline_mae = float(mean_absolute_error(y_val, baseline_preds))
    baseline_rmse = float(np.sqrt(mean_squared_error(y_val, baseline_preds)))

    model = build_rnn()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.005, eps=1e-7)
    loss_fn = nn.L1Loss()

    batch_size = 32
    patience = 100
    best_val_loss = float("inf")
    best_epoch = 0
    best_state = copy.deepcopy(model.state_dict())
    epochs_without_improvement = 0

    for epoch in range(epochs):
        model.train()
        for start in range(0, len(x_train_t), batch_size):
            xb = x_train_t[start : start + batch_size]
            yb = y_train_t[start : start + batch_size]
            optimizer.zero_grad()
            loss = loss_fn(model(xb), yb)
            loss.backward()
            optimizer.step()

        model.eval()
        with torch.no_grad():
            val_loss = float(loss_fn(model(x_val_t), y_val_t))

        if val_loss < best_val_loss:
            best_val_loss = val_loss
            best_epoch = epoch + 1
            best_state = copy.deepcopy(model.state_dict())
            epochs_without_improvement = 0
        else:
            epochs_without_improvement += 1
            if epochs_without_improvement >= patience:
                break

    model.load_state_dict(best_state)
    model.eval()
    with torch.no_grad():
        val_preds = model(x_val_t).cpu().numpy().flatten()
        forecast_price = float(model(x_forecast_t).cpu().numpy().flatten()[0])

    rnn_mae = float(mean_absolute_error(y_val, val_preds))
    rnn_rmse = float(np.sqrt(mean_squared_error(y_val, val_preds)))

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
