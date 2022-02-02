import sqlite3
import pandas as pd
from datetime import datetime
from pathlib import Path
from hashlib import sha1
import yaml

def get_whatsapp_df(chat_file):
    with chat_file.open() as f:
        lines = f.readlines()
        parsed_lines = []
        for line in lines:
           parsed_line = parse_line(line)
           if parsed_line:
               parsed_lines.append(parsed_line)
        df = pd.concat([pd.DataFrame({'date':[date], 'contact':[contact], 'message':[message]}) for date, contact, message in parsed_lines])
    df = df.sort_values('date')
    return df


def parse_line(line):
    line = line.strip('\u200e')
    if line.count(":") >= 3:
        split_line = line.split(':', 3)
        meta_data =  (':').join(split_line[:3])
        message = split_line[-1].strip().strip('\u200e')
        date, name = meta_data.split(']')
        date = date.strip('[')
        date = datetime.strptime(date, '%m/%d/%y, %X')
        name = name.strip()
        return (date, name, message)
    else:
        return False



