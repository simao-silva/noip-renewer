import random
from getpass import getpass
from sys import argv
from time import sleep

import requests
from deep_translator import GoogleTranslator
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.ui import WebDriverWait


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


if __name__ == "__main__":
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
    browser_options = webdriver.FirefoxOptions()
    # browser_options.add_argument("--headless")
    browser_options.add_argument("user-agent=" + str("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36"))
    service = Service(executable_path="/usr/local/bin/geckodriver", log_output="/dev/null")
    browser = webdriver.Firefox(options=browser_options, service=service)

    # LOGIN
    browser.get(LOGIN_URL)

    if browser.current_url == LOGIN_URL:

        try:
            username_input = WebDriverWait(browser, 10).until(lambda browser: browser.find_element(by=By.ID, value="username"))
        except TimeoutException:
            print("Username input not found within the specified timeout.")
            browser.quit()
            exit(1)

        try:
            password_input = WebDriverWait(browser, 10).until(lambda browser: browser.find_element(by=By.ID, value="password"))
        except TimeoutException:
            print("Password input not found within the specified timeout.")
            browser.quit()
            exit(1)

        username_input.send_keys(email)
        password_input.send_keys(password)

        try:
            login_button = WebDriverWait(browser, 10).until(lambda browser: browser.find_element(by=By.ID, value="clogs-captcha-button"))
            login_button.click()
        except TimeoutException:
            print("Login button not found within the specified timeout.")
            browser.quit()
            exit(1)

        wait = WebDriverWait(driver=browser, timeout=20)
        try:
            dashboard_nav = WebDriverWait(driver=browser, timeout=60, poll_frequency=3).until(expected_conditions.visibility_of(browser.find_element(by=By.ID, value="dashboard-nav")))
            print("Login successful")
        except TimeoutException:
            print("Could not login. Check if account is blocked.")
            browser.quit()
            exit(1)

        browser.get(HOST_URL)

        try:
            create_hostname_button = WebDriverWait(driver=browser, timeout=60, poll_frequency=3).until(expected_conditions.visibility_of(browser.find_element(by=By.ID, value="host-panel")))
        except TimeoutException:
            print("Could not load NO-IP hostnames page.")
            browser.quit()
            exit(1)

        # CONFIRM HOSTS
        try:
            hosts = method2()
            print("Confirming hosts phase")
            confirmed_hosts = 0

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
        print("Cannot access login page:\t" + LOGIN_URL)
    browser.quit()
