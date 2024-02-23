import pandas as pd
from selenium import webdriver
from datetime import date
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options as EdgeOptions
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.microsoft import EdgeChromiumDriverManager
from selenium.webdriver.chrome.service import Service
import time
from datetime import datetime, timedelta
import os
import numpy as np
from pathlib import Path
import os

def get_driver_path():
    # Get the home directory of the current user
    home_dir = Path.home()

    # Go up one level to get the parent directory, which should be 'Users' on Windows
    # and '/home' on most Unix-like systems (or '/Users' on macOS)
    users_dir = home_dir.parent
    username = os.getenv('USER') or os.getenv('USERNAME')

    return os.path.join(users_dir,username,'msedgedriver.exe')

# Use the function
edge_path = get_driver_path()
print("Edge path:", edge_path)
def init_driver():
    """Initialize the Selenium Edge driver with automatic driver management."""
    options = webdriver.EdgeOptions()
    return webdriver.Edge(service=Service(EdgeChromiumDriverManager().install()), options=options)

def extract_table_to_df(driver, time_limit, xpath):
    """Extract table data and convert to a dataframe."""
    time.sleep(3)
    outer_html = WebDriverWait(driver, time_limit).until(EC.element_to_be_clickable((By.XPATH, xpath))).get_attribute('outerHTML')
    df = pd.DataFrame(np.concatenate(pd.read_html(outer_html)))
    print(df)

def element_iteration_function():
    company_data =[]
    for i in range(1,101): #Assuming there are 100 elements
        xpath = f"/html/body/div[3]/main/div[3]/div[{i}]/div/div[1]" # Rank and Name
        pass # to do: add ranking and maybe blurb
        try:
            element = WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH,xpath)))
            company_data.append(element.text)
            print(element.text)
        except:
            print(f"Element not found for index {i}")
        
    df = pd.DataFrame(company_data)

def extract_table_to_df(driver, time_limit, xpath, columns,year):
    """Extract table data and convert to a dataframe."""
    time.sleep(3)

    outer_html = WebDriverWait(driver, time_limit).until(EC.element_to_be_clickable((By.XPATH, xpath))).get_attribute('outerHTML')
    
    # Creates dataframe by using numpy contenation of arrays
    df = pd.DataFrame(np.concatenate(pd.read_html(outer_html)))

    print(df)

    # Set columns
    df.columns=columns

    # Add a Ranking column
    df['Rank'], df['Year'] = df.index + 1 , year

    return df
    
def click_button(button_xpath):

        # Wait for the button to become clickable
        button = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, button_xpath))
        )

        # Click the button
        button.click()

        # Add any additional actions after the click if necessary


all_company_data = pd.DataFrame()
div_counter = 10
for year in range(2009,2024):
    with init_driver() as driver:
        year_df = pd.DataFrame()
        for attempt in range(5):
            try:
                driver.get(f"https://www.glassdoor.com/Award/Best-Places-to-Work-{year}-LST_KQ0,24.htm")

                click_button('/html/body/div[3]/main/div[4]/div[2]/a')
                year_df = extract_table_to_df(driver, 15, f'/html/body/div[11]/div[2]/div[2]/div[2]/table',['CompanyName','Rating'],year)
                
            except:
                pass

            if year_df.empty:
                continue
            else:
                all_company_data = pd.concat([all_company_data,year_df])
                break

        
all_company_data.to_csv('GlassDoor.csv')


