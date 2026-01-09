import pandas as pd
import json
import requests
from apiclient.discovery import build
from apiclient.errors import HttpError

from simple_term_menu import TerminalMenu
from tqdm import tqdm
import sqlite3
import sys

def parse_json(file_loc):
    with open(file_loc) as json_file:
        json_list = json.load(json_file)

    json_dict = {'title':[],'video_id':[],'datetime':[]}

    pbar = tqdm(total= len(json_list))
    for video in json_list:
        # print(video)
         if 'details' not in video and 'Watched' in video['title']:
            print(video)
            if 'titleUrl' in video and 'time' in video:
                for key,val in video.items():
                    if key=='time':
                        json_dict['datetime'].append(val)
                        
                    elif key == 'titleUrl':
                        video_id = val.replace('https://www.youtube.com/watch?v=','')
                        json_dict['video_id'].append(video_id)

                    elif key=='title':
                        title = val.replace("Watched ","").strip()
                        json_dict['title'].append(title)
                    
                    pbar.update(1)

    return json_dict


    
def yt_api_channel(conn):
    cursor = conn.cursor()

    channelId_list = cursor.execute("SELECT channelId FROM video_db WHERE channelViewCount IS NULL OR channelId = ''").fetchall()
    pbar = tqdm(total= len(channelId_list))

    print('channels',len(channelId_list))

    for channel_id in channelId_list:
        pbar.update(1)

        current_channel_id = channel_id[0]

        cursor.execute("SELECT EXISTS (SELECT 1 FROM video_db WHERE channelId = ? and channelViewCount IS NULL)", (current_channel_id,)) 

        channel_data_exists = cursor.fetchone()[0] 

        # print(channel_data_exists)

        if channel_data_exists != 0:
            print(f"Processing channelId: {current_channel_id}") 

            part_list = ['snippet','statistics']

            channel_data_dictionary = {
                'channelId': current_channel_id,
                'viewCount': None,
                'subscriberCount': None,
                'videoCount': None,
                'hiddenSubscriberCount': None,
                'videoCount': None,
                'country': None,
                }
            
            request = youtube.channels().list(part=part_list,id=current_channel_id)
            response = request.execute()
            # print(response)

            try:
                if 'items' in response:
                    for yt_part_param,val in response['items'][0].items():
                        if yt_part_param in part_list:
                            for key,val in val.items():
                                    if key in channel_data_dictionary:
                                        channel_data_dictionary[key] = val
                    
                    channel_data_dictionary['channelViewCount'] = channel_data_dictionary.pop('viewCount')
                    channel_data_dictionary['channelVideoCount'] = channel_data_dictionary.pop('videoCount')

                    # print(channel_data_dictionary)

                    columns = ', '.join([f"{column} = :{column}" for column in channel_data_dictionary.keys()])
                    sql = f"UPDATE video_db SET {columns} WHERE channelId = :channelId" 

                    cursor.execute(sql, channel_data_dictionary)
                    conn.commit()

            except:
                print(f"ERROR: channel_id {current_channel_id}")
                print(response)

        else:
            print(f"Channel Exists in db: channel_id {current_channel_id}")

            cursor.execute("SELECT * FROM video_db WHERE channelId = ?", (current_channel_id,))
            row = cursor.fetchone()
            column_names = [description[0] for description in cursor.description]
            channel_data_dict = dict(zip(column_names, row))

            # Safely delete keys if they exist in the dictionary
            video_stats = ['title', 'video_id', 'channelId', 'viewCount', 'likeCount', 'commentCount', 'topicCategories']
            for key in video_stats:
                channel_data_dict.pop(key, None)  # Use pop with default value to avoid KeyError

            # Ensure channelId is in the dictionary for the WHERE clause
            channel_data_dict['channelId'] = current_channel_id

            columns = ', '.join([f"{column} = :{column}" for column in channel_data_dict.keys() if column != 'channelId'])
            sql = f"UPDATE video_db SET {columns} WHERE channelId = :channelId"

            cursor.execute(sql, channel_data_dict)
            conn.commit()

 

def yt_api_video(df, db_conn, db_cursor, table_name):
    pbar = tqdm(total= len(df.index))

    # print(len(df['video_id'].unique())

    # print(len(df['video_id'].unique()))


    for index, row in df.iterrows():
        pbar.update(1)

        current_video_id = row['video_id']

        cursor.execute(f"SELECT EXISTS (SELECT 1 FROM {table_name} WHERE video_id = ?)", (current_video_id,))

        video_exists_result = cursor.fetchone()[0] 
        
        # the video does not exist in db
        if video_exists_result == 0:

            part_list = ['snippet','statistics','topicDetails']
            request = youtube.videos().list(part=['snippet','statistics','topicDetails'],id=current_video_id)

            # try:   
            response = request.execute()
            
            video_data_dictionary = {
                'title': None,
                'video_id': current_video_id,
                'channelId': None,
                'channelTitle': None,
                'viewCount': None,
                'likeCount': None,
                'commentCount': None,
                'topicCategories': None
                }
            
            # print(response)

            if len(response['items']) != 0:
            
                for yt_part_param,val in response['items'][0].items():
                    if yt_part_param in part_list:
                        for key,val in val.items():
                            if key == 'topicCategories':
                                video_topic_parsed = val[0].replace('https://en.wikipedia.org/wiki/','')
                                video_data_dictionary[key] = video_topic_parsed

                            elif key in video_data_dictionary:
                                video_data_dictionary[key] = val
                
                columns = ', '.join(video_data_dictionary.keys())
                placeholders = ', '.join(['?'] * len(video_data_dictionary))

                sql = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"

                db_cursor.execute(sql, tuple(video_data_dictionary.values()))
                db_conn.commit()

                print(f"Success [new]: video_id {current_video_id}")

                ### process channel info

                current_channle_id = video_data_dictionary['channelId']

                cursor.execute("SELECT EXISTS (SELECT 1 FROM video_db WHERE channelId = ? and channelViewCount IS NULL)", (current_channle_id,)) 

                channel_data_exists = cursor.fetchone()[0] 

                # if channel_data_exists != 0:
                #     get_channel_stats_api()


            # except:
            #     print(f"ERROR: video_id {current_video_id}")
            #     # print(response)

        else:
            print(f"Success [existed] : video_id {current_video_id}")


               
    pbar.close()
  

def db_to_csv(parsed_df, cursor):
    pbar = tqdm(total= len(parsed_df.index))

    parsed_df = parsed_df[["video_id","datetime"]]

    for index, row in parsed_df.iterrows():
        pbar.update(1)

        video_id = row['video_id']

        cursor.execute("SELECT * FROM video_db WHERE video_id = ?", (video_id,))

        try:
            video_data = cursor.fetchone()
            column_names = [description[0] for description in cursor.description]

            video_data_dict = dict(zip(column_names, video_data))

            video_stats = ['video_id']
            for key in video_stats:
                del video_data_dict[key]

            for key, val in video_data_dict.items():
                # If the value is empty (None, empty string, or empty list), set to None
                if val in [None, '', [], {}]:
                    parsed_df.loc[index, key] = 'N/A'
                else:
                    parsed_df.loc[index, key] = val
        except:
            print(f"Error: video {video_id} does not exist")
    
    return parsed_df


        



def menu():
    options = ["json to csv", "video stats", "channel stats", "get data csv", "quit"]
    terminal_menu = TerminalMenu(options)
    menu_entry_index = terminal_menu.show()
    option = options[menu_entry_index]

    return option

if __name__ == '__main__':

    api_key_file = open("data/api_key.txt","r")
    api_key = api_key_file.readline().replace(" ","")

    youtube = build('youtube','v3',developerKey = api_key)

    print ("-"*25)
    print("----- YOUTUBE DATA ----- ")
    print ("-"*25)

    option = menu()

    # print(sys.argv)
    student_name = sys.argv[1]

    while option != "quit":
        if option == "json to csv":
            json_dict = parse_json(f"data/{student_name}-watch-history.json")
            json_to_csv_df = pd.DataFrame.from_dict(json_dict)
        
            json_to_csv_df.to_csv(f"export/{student_name}-json-parsed.csv",index=None)

        

        elif option == 'video stats':
            json_parsed_df = pd.read_csv(f"export/{student_name}-json-parsed.csv")

            print("-"*20)
            print("Fetching Youtube video stats...")

            conn = sqlite3.connect("youtube.db")
            cursor = conn.cursor()

            yt_api_video(json_parsed_df, conn, cursor, "video_db")

        elif option == 'channel stats':
            print("-"*20)
            print("Fetching Youtube channel stats...")

            conn = sqlite3.connect("youtube.db")

            channel_df = yt_api_channel(conn)
            

        elif option == 'get data csv':
            parsed_csv = pd.read_csv(f"export/{student_name}-json-parsed.csv")

            conn = sqlite3.connect("youtube.db")
            cursor = conn.cursor()

            processed_df = db_to_csv(parsed_csv, cursor)
            processed_df.to_csv(f"export/{student_name}-youtube.csv",index=None)

           

        print("\n")
        option = menu()
