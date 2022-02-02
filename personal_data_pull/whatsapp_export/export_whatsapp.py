from whatsapp_df import get_whatsapp_df
from pathlib import Path
import shutil
import os
from pathlib import Path
import tempfile
import zipfile
import pandas as pd


DATA_DIR = "data"
EXPORT_DIR = Path("./export")
OUTFILE = "whatsapp.csv"

def get_chat_df(zipped_chat):
    with tempfile.TemporaryDirectory() as tmp_chat_dir:
        tmp_submission_dir = Path(tmp_chat_dir)
        with zipfile.ZipFile(zipped_chat, mode='r') as zip_ref:
            chat_file = (zipfile.Path(zip_ref) / "_chat.txt")
            df = get_whatsapp_df(chat_file)
            chat_name = zip_ref.filename.split(" - ")[1].split(".")[0] 
            df['chat_name'] = chat_name
            return df

def export_whatsapp_to_csv():
    chat_dfs_list = []
    data_dir = Path(DATA_DIR)
    for child in data_dir.iterdir():
        if child.suffix == ".zip":
                df = get_chat_df(child)
                chat_dfs_list.append(df)
    chat_dfs = pd.concat(chat_dfs_list)
    chat_dfs = chat_dfs.sort_values('date')
    chat_dfs.to_csv(EXPORT_DIR / "whatsapp.csv")

if __name__ == '__main__':
    export_whatsapp_to_csv()
