import random
from getpass import getpass
from sys import argv
from time import sleep

import requests
from deep_translator import GoogleTranslator
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.service import Service

import os


def method1():
    return browser \
        .find_element(by=By.XPATH, value="/html/body/div[1]/div/div/div[3]/div[1]/div[2]/div/div/div[1]/div[1]/table/tbody") \
        .find_elements(by=By.TAG_NAME, value="tr")


def method2():
    return browser \
        .find_element(by=By.ID, value="host-panel") \
        .find_element(by=By.TAG_NAME, value="table") \
        .find_element(by=By.TAG_NAME, value="tbody") \
        .find_elements(by=By.TAG_NAME, value="tr")


def translate(text):
    return GoogleTranslator(source='auto', target='en').translate(text=text)


def get_user_agent():
    r = requests.get(url="https://jnrbsn.github.io/user-agents/user-agents.json")
    if r.status_code == 200 and len(list(r.json())) > 0:
        agents = r.json()
        return list(agents).pop(random.randint(0, len(agents) - 1))
    else:
        return "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.63 Safari/537.36"


def get_credentials():
    """
    Retrieves the credentials required for authentication.

    Returns:
        - email (str): The email address associated with the credentials.
        - password (str): The password associated with the credentials.

    Notes:
        - The function first checks if the email and password are already set as environment variables.
        - If the email or password is not set, it checks if the command line arguments were passed.
        - If the email or password is still not set, it prompts the user to enter the values interactively.
    """
    email= os.environ["NO_IP_USERNAME"]
    password = os.environ["NO_IP_PASSWORD"]
    if((email == None or len(email) == 0) or (password == None or len(password) == 0)):
        if(len(argv) == 3):
            if(email == None):
                email = argv[1]
            if(password == None):
                password = argv[2]
        else:
            if(email == None):
                email = str(input("Email: ")).replace("\n", "")
            if(password == None):
                password = getpass("Password: ").replace("\n", "")
        email = str(input("Email: ")).replace("\n", "")
        password = getpass("Password: ").replace("\n", "")

    return email,password


if __name__ == "__main__":
    LOGIN_URL = "https://www.noip.com/login?ref_url=console"
    HOST_URL = "https://my.noip.com/dynamic-dns"
    LOGOUT_URL = "https://my.noip.com/logout"

    email, password = get_credentials()

    # OPEN BROWSER
    print("Opening browser")
    browser_options = webdriver.FirefoxOptions()
    browser_options.add_argument("--headless")
    browser_options.add_argument("user-agent=" + str(get_user_agent()))

    service = Service(executable_path="/usr/local/bin/geckodriver", log_output="/dev/null")

    browser = webdriver.Firefox(options=browser_options, service=service)

    # LOGIN
    browser.get(LOGIN_URL)

    if browser.current_url == LOGIN_URL:

        browser.find_element(by=By.NAME, value="username").send_keys(email)
        browser.find_element(by=By.NAME, value="password").send_keys(password)

        login_button = False

        for button in browser.find_elements(by=By.TAG_NAME, value="button"):
            if button.text == "Log In":
                button.click()
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
                            button = host.find_element(by=By.TAG_NAME, value="button")
                        except NoSuchElementException as e:
                            break

                        if button.text == "Confirm" or translate(button.text) == "Confirm":
                            button.click()
                            confirmed_host = host.find_element(by=By.TAG_NAME, value="a").text
                            confirmed_hosts += 1
                            print("Host \"" + confirmed_host + "\" confirmed")
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
