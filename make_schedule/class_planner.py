import pandas as pd
from datetime import datetime, timedelta

input_file = 'input.csv'  # Replace with the actual input file name

# Read the input CSV file into a pandas DataFrame
df = pd.read_csv(input_file)

# excludes useless columns
columns_to_exclude = ["NOTE", "START_TIME", "MINUTES_ATTENDED", "LOCATION"]
df.drop(columns=columns_to_exclude, inplace=True)

# stores all unique classes 
classes = df["SUMMARY"].unique()

# loops through each class 
for class_name in classes:
    class_df = df.query("SUMMARY == @class_name")
    output_file = f'export/{class_name}.csv'  # Replace with the desired output file name

    new_df = pd.DataFrame(columns=['DESCRIPTION', 'DATE_VALUE',"LAB","NOTES"])

    # creates df with current class 
    temp_df = df.query("SUMMARY == 'G09 Shuyuan Computer Science (9SCS.1)'")

    # gets current week number
    first_date_value = pd.to_datetime(df['DATE_VALUE'].iloc[0])
    previous_week = first_date_value.week

    week_num = 1

    # loops through rows in df
    for index, row in class_df.iterrows():
        # Access row values using column names
        # summary = row['SUMMARY']
        description = row['DESCRIPTION']
        date_value = row['DATE_VALUE']

        new_row = {
        # 'SUMMARY': summary, 
        'DESCRIPTION': description, 
        'DATE_VALUE': date_value}

        current_week_number = pd.to_datetime(date_value).week

        if current_week_number != previous_week: 
            week_row = {
                # 'SUMMARY': f"Week {week_num}", 
                'DESCRIPTION': f"Week {week_num}", 
                'DATE_VALUE': f"Week {week_num}",
                'LAB': f"Week {week_num}",
                'NOTES': f"Week {week_num}"}
            
            new_df = new_df._append(week_row, ignore_index=True)

            previous_week = current_week_number 
            week_num += 1

        new_df = new_df._append(new_row, ignore_index=True)

    new_df.to_csv(output_file, index=False)

    print(f"Modified CSV exported to {output_file}")