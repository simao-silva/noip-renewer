from selenium import webdriver
from getpass import getpass
from time import sleep
from sys import argv
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException
from googletrans import Translator
import requests
import random


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
    translator = Translator()
    result = translator.translate(text, dest='en')
    return result.text


def get_user_agent():
    r = requests.get(url="https://jnrbsn.github.io/user-agents/user-agents.json")
    if r.status_code == 200:
        agents = r.json()
        return list(agents).pop(random.randint(0, len(agents)))
    else:
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36"


LOGIN_URL = "https://www.noip.com/login?ref_url=console"
HOST_URL = "https://my.noip.com/dynamic-dns"
LOGOUT_URL = "https://my.noip.com/logout"

# ASK CREDENTIALS
if len(argv) == 3:
    email = argv[1]
    password = argv[2]
else:
    email = str(input("Email: ")).replace("\n", "")
    password = getpass("Password: ").replace("\n", "")

# OPEN BROWSER
print("Opening browser")
browserOptions = webdriver.ChromeOptions()
browserOptions.add_argument("--headless")
browserOptions.add_argument("--no-sandbox")
browserOptions.add_argument("disable-gpu")
browserOptions.add_argument("user-agent=" + str(get_user_agent()))

browser = webdriver.Chrome(options=browserOptions)

# LOGIN
browser.get(LOGIN_URL)

if browser.current_url == LOGIN_URL:

    browser.find_element(by=By.NAME, value="username").send_keys(email)
    browser.find_element(by=By.NAME, value="password").send_keys(password)

    login_button = False

    for i in browser.find_elements(by=By.TAG_NAME, value="button"):
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
