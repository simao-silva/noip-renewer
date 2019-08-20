from selenium import webdriver
from getpass import getpass
from time import sleep
from sys import argv
import platform
import os


def method1():
    table = browser.find_element_by_xpath("//*[@id=\"host-panel\"]/table/tbody")
    return table.find_elements_by_tag_name("tr")


def method2():
    div = browser.find_element_by_id("host-panel")
    table = div.find_element_by_tag_name("table")
    body = table.find_element_by_tag_name("tbody")
    return body.find_elements_by_tag_name("tr")


LOGIN_URL = "https://www.noip.com/login"
HOST_URL = "https://my.noip.com/#!/dynamic-dns"
LOGOUT_URL = "https://my.noip.com/logout"

# ASK CREDENTIALS
if len(argv) == 3:
    email = argv[1]
    password = argv[2]
else:
    email = str(input("Email: "))
    password = getpass("Password: ")

# OPEN BROWSER
print("Opening browser")
browserOptions = webdriver.FirefoxOptions()
browserOptions.add_argument("--headless")

if platform.machine().find("arm") >= 0:
    os.system("tar zxvf drivers/geckodriver-v0.23.0-arm7hf.tar.gz >/dev/null 2>&1")
elif platform.machine().find("x86_64") >= 0:
    os.system("tar zxvf drivers/geckodriver-v0.24.0-linux64.tar.gz >/dev/null 2>&1")
elif platform.machine().find("i386") >= -1:
    os.system("tar zxvf drivers/geckodriver-v0.24.0-linux32.tar.gz >/dev/null 2>&1")

browser = webdriver.Firefox(options=browserOptions, executable_path=r"./geckodriver")

# LOGIN
print("Login page")
browser.get(LOGIN_URL)
username_input = browser.find_element_by_name("username")
password_input = browser.find_element_by_name("password")
username_input.send_keys(email)
password_input.send_keys(password)
login_button = browser.find_element_by_name("Login")
login_button.click()

# RENEW HOSTS
try:
    browser.get(HOST_URL)
    hosts = method2()

    for host in hosts:
        # print("Host: " + host.text)
        confirmation_button = host.find_element_by_tag_name("button")
        if confirmation_button.text == "Confirm":
            confirmation_button.click()
            confirmed_host = host.find_element_by_tag_name("a").text
            print("Host: " + confirmed_host + " confirmed")
            sleep(0.25)

except Exception as e:
    print("Error: ", e)

finally:
    browser.get(LOGOUT_URL)
    browser.quit()
