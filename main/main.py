# import pandas as pd
# from pathlib import Path
# import os


# raw_folder = Path(r"D:\project1\stock_price 2021 2026\raw")



# print("Current folder:", os.getcwd())
# print("Raw folder exists:", raw_folder.exists())
# print("CSV files:", list(raw_folder.glob("*.csv")))

# dataframes = []

# for file in raw_folder.rglob("*.csv"):
#     if file.name == "all_cleaned.csv":
#         continue

#     df = pd.read_csv(file)

#     rename = {
#         "Date": "date",
#         "Open": "open",
#         "High": "high",
#         "Low": "low",
#         "Close": "close",
#         "Volume": "volume",
#         "Dividends": "dividends",
#         "Stock Splits": "stock_splits",
#         "Capital Gains": "capital_gains"
#     }

#     df.rename(columns=rename, inplace=True)
#     df.drop_duplicates()

#     df["date"] = df["date"].str.replace(
#         "00:00:00+02:00", "", regex=False
#     )
#     df["date"] = df["date"].str.replace(
#         "00:00:00+03:00", "", regex=False
#     )
#     df["date"] = df["date"].str.replace(
#         "00:00:00+00:00", "", regex=False
#     )
#     df["date"] = pd.to_datetime(df["date"], errors="coerce", utc=True)


#     # df["date"] = df["date"].dt.strftime("%Y-%m-%d")
#     # df["date"] = pd.to_datetime(df["date"], errors="coerce", utc=True)
#     # df["date"] = pd.to_datetime(df["date"], errors="coerce").dt.normalize()
#     df["date"] = pd.to_datetime(df["date"], errors="coerce").dt.date
#     dataframes.append(df)

# if dataframes:
#     final_df = pd.concat(dataframes, ignore_index=True)
#     final_df.to_csv(
#     r"D:\project1\AI-Investment-Advisor-Platform\data\all_cleaned.csv",
#     index=False)

# print(os.getcwd())
    
# print(df["date"].dtype)
# print(dataframes)


import pandas as pd
from pathlib import Path
import os

raw_folder = Path(r"D:\project1\stock_price 2021 2026\raw")
output_file = Path(r"D:\project1\AI-Investment-Advisor-Platform\data\all_cleaned.csv")

print("Current folder:", os.getcwd())
print("Raw folder exists:", raw_folder.exists())

dataframes = []

rename = {
    "Date": "date",
    "Open": "open",
    "High": "high",
    "Low": "low",
    "Close": "close",
    "Volume": "volume",
    "Dividends": "dividends",
    "Stock Splits": "stock_splits",
    "Capital Gains": "capital_gains",
}

for file in raw_folder.rglob("*.csv"):
    if file.name == "all_cleaned.csv":
        continue

    df = pd.read_csv(file)
    df.rename(columns=rename, inplace=True)
    df.drop_duplicates(inplace=True)

    # اسم مجلد الشركة التي يحتوي على ملف CSV
    df["ticker"] = file.parent.name

    if "date" in df.columns:
        df["date"] = df["date"].astype("string")
        df["date"] = df["date"].str.replace(
            r"00:00:00[+-]\d{2}:\d{2}", "", regex=True
        )
        df["date"] = pd.to_datetime(
            df["date"], errors="coerce", utc=True
        ).dt.date

    # حذف أي صف يحتوي على قيمة رقمية سالبة
    df = df[~df.select_dtypes(include="number").lt(0).any(axis=1)]

    dataframes.append(df)

if dataframes:
    final_df = pd.concat(dataframes, ignore_index=True)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    final_df.to_csv(output_file, index=False)

    print("Saved to:", output_file)
    print("Rows:", len(final_df))
else:
    print("No CSV files found.")