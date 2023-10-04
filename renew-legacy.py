from getpass import getpass
import os
from sys import argv
from time import sleep

from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException


def method1():
    return browser \
        .find_element_by_xpath("/html/body/div[1]/div/div/div[3]/div[1]/div[2]/div/div/div[1]/div[1]/table/tbody") \
        .find_elements_by_tag_name("tr")


def method2():
    return (
        browser.find_element_by_id("host-panel")
        .find_element_by_tag_name("table")
        .find_element_by_tag_name("tbody")
        .find_elements_by_tag_name("tr")
    )


LOGIN_URL = "https://www.noip.com/login?ref_url=console"
HOST_URL = "https://my.noip.com/dynamic-dns"
LOGOUT_URL = "https://my.noip.com/logout"

# GET CREDENTIALS
email = None
password = None
if ('NO_IP_USERNAME' in os.environ and 'NO_IP_PASSWORD' in os.environ):
    email = os.environ['NO_IP_USERNAME']
    password = os.environ['NO_IP_PASSWORD']
    if (email != None and len(email) > 0 and password != None and len(password) > 0):
        email = os.environ['NO_IP_USERNAME']
        password = os.environ['NO_IP_PASSWORD']
else:
    if (len(argv) == 3):
        if (email == None):
            email = argv[1]
        if (password == None):
            password = argv[2]
    else:
        if (email == None):
            email = str(input("Email: ")).replace("\n", "")
        if (password == None):
            password = getpass("Password: ").replace("\n", "")



# OPEN BROWSER
print("Opening browser")
browserOptions = webdriver.ChromeOptions()
browserOptions.add_argument("--headless")
browserOptions.add_argument("--no-sandbox")
browserOptions.add_argument("disable-gpu")

browser = webdriver.Chrome(options=browserOptions)

# LOGIN
browser.get(LOGIN_URL)

if browser.current_url == LOGIN_URL and browser.title == "Log In - No-IP":
    browser.find_element_by_name("username").send_keys(email)
    browser.find_element_by_name("password").send_keys(password)

    login_button = False
    for i in browser.find_elements_by_tag_name("button"):
        if i.text == "Log In":
            i.click()
            login_button = True
            break

    if not login_button:
        print("Login button has changed. Please contact support. ")
        exit(1)

    sleep(2)

    if str(browser.current_url).endswith("noip.com/"):
        print("Login successful")
        browser.get(HOST_URL)
        sleep(1)

        aux = 1
        while not browser.title.startswith("My No-IP") and aux < 3:
            browser.get(HOST_URL)
            sleep(3)
            aux += 1

        if browser.title.startswith("My No-IP") and aux < 4:
            confirmed_hosts = 0

            # RENEW HOSTS
            try:
                hosts = method2()
                print("Confirming hosts phase")

                for host in hosts:
                    try:
                        button = host.find_element_by_tag_name("button")
                    except NoSuchElementException as e:
                        break

                    if button.text == "Confirm":
                        button.click()
                        confirmed_host = host.find_element_by_tag_name("a").text
                        confirmed_hosts += 1
                        print('Host "' + confirmed_host + '" confirmed')
                        sleep(0.25)

                if confirmed_hosts == 1:
                    print("1 host confirmed")
                else:
                    print(str(confirmed_hosts) + " hosts confirmed")

                print("Finished")

            except Exception as e:
                print("Error: ", e)

            finally:
                print("Logging off\n\n")
                browser.get(LOGOUT_URL)
    else:
        print("Error: cannot login. Check if account is not blocked.")
        print("Logging off\n\n")
        browser.get(LOGOUT_URL)
else:
    print("Cannot access login page:\t" + LOGIN_URL)
browser.quit()
