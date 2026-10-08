import pandas as pd
df=pd.read_csv(r"D:\project1\stock_price 2021 2026\raw\SWDY_El Sewedy Electric\SWDY.csv")

rename={
    "Date":"date",
    "Open":"open",
    "Hight":"hight",
    "Low":"low",
    "Close":"close",
    "Volume":"volume",
    "Dividends":"dividends",
    "Stock Splits":"stock_splits",
    "Capital Gains":"capital_gains"
}
df.rename(columns=rename,inplace=True)
df.drop_duplicates()
print(df["date"])
df.to_csv("stock_swdy.csv",index=False)