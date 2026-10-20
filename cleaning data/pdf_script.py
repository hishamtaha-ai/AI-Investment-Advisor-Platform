
import pymupdf as fitz
import json
import os
import glob

# Folder that contains PDF files
folder_path = input("Enter folder path: ")

# Get all PDF files in the folder
pdf_files = glob.glob(os.path.join(folder_path, "*.pdf"))

# Loop through every PDF file
for pdf_path in pdf_files:
    pdf = fitz.open(pdf_path)

    data = {
        "file_name": os.path.basename(pdf_path),
        "pages": []
    }

    # Read every page
    for page_number, page in enumerate(pdf, start=1):
        data["pages"].append({
            "page_number": page_number,
            "text": page.get_text()
        })

    # Create JSON file path
    json_path = os.path.splitext(pdf_path)[0] + ".json"

    # Save JSON file
    with open(json_path, "w", encoding="utf-8") as file:
        json.dump(data, file, ensure_ascii=False, indent=4)

    pdf.close()
    print("Converted:", os.path.basename(pdf_path))

print("All PDF files converted!")
