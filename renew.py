import os
import random
from getpass import getpass
from sys import argv
from time import sleep

import pyotp
import requests
from deep_translator import GoogleTranslator
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.ui import WebDriverWait


def get_hosts():
    return (
        browser.find_element(by=By.CLASS_NAME, value="zone-container")
        .find_elements(by=By.CLASS_NAME, value="flex-row")
    )


def translate(text):
    if str(os.getenv("TRANSLATE_ENABLED", True)).lower() == "true":
        return GoogleTranslator(source="auto", target="en").translate(text=text)
    return text


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


def validate_otp(code):
    valid = True

    if len(code) != 6:
        exit_with_error(
            message="Invalid email verification code. The code must have 6 digits. Exiting."
        )
        valid = False
    if otp_code.isnumeric() is False:
        exit_with_error("Email verification code must be numeric. Exiting.")
        valid = False

    return valid


def validate_2fa(code):
    if len(code) != 16 or code.isalnum() is False:
        exit_with_error(
            message="Invalid 2FA key. Key must have 16 alphanumeric characters. Exiting."
        )
        return False
    return True


if __name__ == "__main__":
    LOGIN_URL = "https://www.noip.com/login?ref_url=console"
    HOST_URL = "https://my.noip.com/dynamic-dns"
    LOGOUT_URL = "https://my.noip.com/logout"

    HOSTNAME_PREFIX = "expiration-banner-hostname-"

    email, password = get_credentials()

    # Set up browser
    profile = FirefoxProfile()
    profile.set_preference("general.useragent.override", get_user_agent())
    browser_options = webdriver.FirefoxOptions()
    browser_options.add_argument("--headless")
    browser_options.profile = profile
    service = Service(
        executable_path="/usr/local/bin/geckodriver", log_output="/dev/null"
    )
    browser = webdriver.Firefox(options=browser_options, service=service)

    # Open browser
    print(
        'Using user agent "'
        + browser.execute_script("return navigator.userAgent;")
        + '"'
    )
    print("Opening browser")

    # Go to login page
    browser.get(LOGIN_URL)

    if browser.current_url == LOGIN_URL:

        # Find and fill login form
        try:
            username_input = WebDriverWait(browser, 10).until(
                lambda browser: browser.find_element(by=By.ID, value="username")
            )
        except TimeoutException:
            exit_with_error(
                message="Username input not found within the specified timeout."
            )

        try:
            password_input = WebDriverWait(browser, 10).until(
                lambda browser: browser.find_element(by=By.ID, value="password")
            )
        except TimeoutException:
            exit_with_error(
                message="Password input not found within the specified timeout."
            )

        username_input.send_keys(email)
        password_input.send_keys(password)

        # Find and click login button
        try:
            WebDriverWait(driver=browser, timeout=60, poll_frequency=3).until(
                expected_conditions.visibility_of_element_located(
                    (By.ID, "clogs-captcha-button")
                )
            )
            login_button = browser.find_element(By.ID, "clogs-captcha-button")
            login_button.click()
        except TimeoutException:
            exit_with_error(
                message="Login button not found within the specified timeout."
            )

        # Wait for login to complete
        try:
            WebDriverWait(driver=browser, timeout=60, poll_frequency=3).until(
                expected_conditions.visibility_of_any_elements_located(
                    (By.CLASS_NAME, "nav-link")
                )
            )
        except TimeoutException:
            exit_with_error(message="Could not do post login action. Exiting.")

        # Check if login has 2FA enabled and handle it
        if browser.current_url.find("2fa") > -1:

            # Wait for submit button to ensure page is loaded
            try:
                WebDriverWait(driver=browser, timeout=60, poll_frequency=3).until(
                    expected_conditions.element_to_be_clickable((By.NAME, "submit"))
                )
                submit_button = browser.find_elements(By.NAME, "submit")
                if len(submit_button) < 1:
                    exit_with_error(message="2FA submit button not found. Exiting.")
            except TimeoutException:
                exit_with_error(
                    message="2FA page did not load within the specified timeout. Exiting."
                )
            except NoSuchElementException:
                exit_with_error(message="2FA submit button not found. Exiting.")

            # Find if account has 2FA enabled or if is relying on email verification code
            CODE_METHOD = None
            try:
                code_form = browser.find_element(by=By.ID, value="otp-input")
                CODE_METHOD = "email"
            except NoSuchElementException:
                try:
                    code_form = browser.find_element(by=By.ID, value="challenge_code")
                    CODE_METHOD = "app"
                except NoSuchElementException:
                    exit_with_error(message="2FA/Email code input not found. Exiting.")

            # Account has email verification code
            if CODE_METHOD == "email":
                otp_code = str(input("Enter OTP code: ")).replace("\n", "")
                if validate_otp(otp_code):
                    code_inputs = code_form.find_elements(by=By.TAG_NAME, value="input")
                    if len(code_inputs) == 6:
                        for i in range(len(code_inputs)):
                            code_inputs[i].send_keys(otp_code[i])
                    else:
                        exit_with_error(message="Email code input not found. Exiting.")

            # Account has 2FA code
            elif CODE_METHOD == "app":
                totp_secret = os.getenv("NO_IP_TOTP_KEY", "")
                if len(totp_secret) == 0:
                    totp_secret = str(input("Enter 2FA key: ")).replace("\n", "")
                if validate_2fa(totp_secret):
                    totp = pyotp.TOTP(totp_secret)
                    browser.execute_script("arguments[0].focus();", code_form)
                    ActionChains(browser).send_keys(totp.now()).perform()

            # Click submit button
            submit_button[0].click()

        # Wait for account dashboard to load
        try:
            WebDriverWait(driver=browser, timeout=120, poll_frequency=3).until(
                expected_conditions.visibility_of_element_located(
                    (By.ID, "content-wrapper")
                )
            )
            print("Login successful")
        except TimeoutException:
            exit_with_error(message="Could not login. Check if account is blocked.")
        except NoSuchElementException:
            exit_with_error(message="Could not find element dashboard menu. Exiting.")

        # Go to hostnames page
        browser.get(HOST_URL)

        # Wait for hostnames page to load
        try:
            WebDriverWait(driver=browser, timeout=60, poll_frequency=3).until(
                expected_conditions.visibility_of(
                    browser.find_element(by=By.CLASS_NAME, value="zone-container")
                )
            )
        except TimeoutException:
            exit_with_error(message="Could not load NO-IP hostnames page.")

        # Confirm hosts
        try:
            hosts = get_hosts()
            print("Confirming hosts phase")
            confirmed_hosts = 0

            for host in hosts:
                if HOSTNAME_PREFIX in host.get_attribute('id'):
                    current_host = host.get_attribute('id')[28]
                    print('Host "' + current_host + '" needs confirmation')
                    try:
                        button = host.find_element(by=By.TAG_NAME, value="button")
                    except NoSuchElementException as e:
                        break

                    if button.text == "Confirm" or translate(button.text) == "Confirm":
                        button.click()
                        confirmed_hosts += 1
                        print('Host "' + current_host + '" confirmed')
                        sleep(5)  # Wait to avoid error "Element XXXX is not clickable at point (x,y) because another element XXXX obscures it"

            if confirmed_hosts == 1:
                print("1 host confirmed")
            else:
                print(str(confirmed_hosts) + " hosts confirmed")

            print("Finished")

        except Exception as e:
            print("Error: ", e)

        # Log off
        finally:
            print("Logging off\n\n")
            browser.get(LOGOUT_URL)
    else:
        print("Cannot access login page:\t" + LOGIN_URL)
    browser.quit()
