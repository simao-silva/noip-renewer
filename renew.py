from selenium import webdriver
from getpass import getpass
from time import sleep
from sys import argv


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
    email = str(input("Email: ")).replace("\n", "")
    password = getpass("Password: ").replace("\n", "")

# OPEN BROWSER
print("Opening browser")
browserOptions = webdriver.ChromeOptions()
browserOptions.add_argument("--headless")
browserOptions.add_argument("--no-sandbox")
browserOptions.add_argument("disable-gpu")

browser = webdriver.Chrome(options=browserOptions)

# LOGIN
print("Login page")
browser.get(LOGIN_URL)
if browser.title == "Log In - No-IP":
    browser.find_element_by_name("username").send_keys(email)
    browser.find_element_by_name("password").send_keys(password)
    browser.find_element_by_name("Login").click()

    browser.get(HOST_URL)
    if browser.title == "My No-IP :: Hostnames":

        # RENEW HOSTS
        try:
            hosts = method2()

            for host in hosts:
                # print("Host: " + host.text)
                button = host.find_element_by_tag_name("button")
                if button.text == "Confirm":
                    button.click()
                    confirmed_host = host.find_element_by_tag_name("a").text
                    print("Host \"" + confirmed_host + "\" confirmed")
                    sleep(0.25)

            print("Finished")

        except Exception as e:
            print("Error: ", e)

        finally:
            browser.get(LOGOUT_URL)
    else:
        print("Error: cannot login. Check if account is not blocked.")
        browser.get(LOGOUT_URL)
browser.quit()
