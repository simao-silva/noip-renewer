import os
import random
from getpass import getpass
from sys import argv
from time import sleep

import requests
from deep_translator import GoogleTranslator
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.ui import WebDriverWait


def get_hosts():
    return browser \
        .find_element(by=By.ID, value="host-panel") \
        .find_element(by=By.TAG_NAME, value="table") \
        .find_element(by=By.TAG_NAME, value="tbody") \
        .find_elements(by=By.TAG_NAME, value="tr")


def translate(text):
    return GoogleTranslator(source='auto', target='en').translate(text=text)


def get_user_agent():
    r = requests.get(url="https://jnrbsn.github.io/user-agents/user-agents.json")
    r.close()
    if r.status_code == 200 and len(list(r.json())) > 0:
        agents = r.json()
        return list(agents).pop(random.randint(0, len(agents) - 1))
    else:
        return "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.63 Safari/537.36"


def exit_with_error(message):
    print(str(message))
    browser.quit()
    exit(1)


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

    email = os.getenv("NO_IP_USERNAME", "")
    password = os.getenv("NO_IP_PASSWORD", "")

    if len(email) == 0 or len(password) == 0:
        if len(argv) == 3:
            email = argv[1]
            password = argv[2]
        else:
            email = str(input("Email: ")).replace("\n", "")
            password = getpass("Password: ").replace("\n", "")

    return email, password


if __name__ == "__main__":
    LOGIN_URL = "https://www.noip.com/login?ref_url=console"
    HOST_URL = "https://my.noip.com/dynamic-dns"
    LOGOUT_URL = "https://my.noip.com/logout"

    email, password = get_credentials()

    # Set up browser
    profile = FirefoxProfile()
    profile.set_preference("general.useragent.override", get_user_agent())
    browser_options = webdriver.FirefoxOptions()
    browser_options.add_argument("--headless")
    browser_options.profile = profile
    service = Service(executable_path="/usr/local/bin/geckodriver", log_output="/dev/null")
    browser = webdriver.Firefox(options=browser_options, service=service)

    # OPEN BROWSER
    print("Using user agent: " + browser.execute_script("return navigator.userAgent;"))
    print("Opening browser")

    # LOGIN
    browser.get(LOGIN_URL)

    if browser.current_url == LOGIN_URL:
        try:
            username_input = WebDriverWait(browser, 10).until(lambda browser: browser.find_element(by=By.ID, value="username"))
        except TimeoutException:
            exit_with_error(message="Username input not found within the specified timeout.")

        try:
            password_input = WebDriverWait(browser, 10).until(lambda browser: browser.find_element(by=By.ID, value="password"))
        except TimeoutException:
            exit_with_error(message="Password input not found within the specified timeout.")

        username_input.send_keys(email)
        password_input.send_keys(password)

        try:
            WebDriverWait(driver=browser, timeout=60, poll_frequency=3).until(expected_conditions.element_to_be_clickable((By.ID, "clogs-captcha-button")))
            login_button = browser.find_element(By.ID, "clogs-captcha-button")
            login_button.click()
        except TimeoutException:
            exit_with_error(message="Login button not found within the specified timeout.")

        try:
            WebDriverWait(driver=browser, timeout=120, poll_frequency=3).until(expected_conditions.visibility_of_element_located((By.ID, "dashboard-nav")))
            print("Login successful")
        except TimeoutException:
            exit_with_error(message="Could not login. Check if account is blocked.")
        except NoSuchElementException:
            exit_with_error(message="Could not find element \"dashboard-nav\". Exiting.")

        browser.get(HOST_URL)

        try:
            WebDriverWait(driver=browser, timeout=60, poll_frequency=3).until(expected_conditions.visibility_of(browser.find_element(by=By.ID, value="host-panel")))
        except TimeoutException:
            exit_with_error(message="Could not load NO-IP hostnames page.")

        # CONFIRM HOSTS
        try:
            hosts = get_hosts()
            print("Confirming hosts phase")
            confirmed_hosts = 0

            for host in hosts:
                current_host = host.find_element(by=By.TAG_NAME, value="a").text
                print("Checking if host \"" + current_host + "\" needs confirmation")
                try:
                    button = host.find_element(by=By.TAG_NAME, value="button")
                except NoSuchElementException as e:
                    break

                if button.text == "Confirm" or translate(button.text) == "Confirm":
                    button.click()
                    confirmed_hosts += 1
                    print("Host \"" + current_host + "\" confirmed")
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
