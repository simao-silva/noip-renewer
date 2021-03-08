from selenium import webdriver
from getpass import getpass
from time import sleep
from sys import argv


def method1():
    return browser \
        .find_element_by_xpath("//*[@id=\"host-panel\"]/table/tbody") \
        .find_elements_by_tag_name("tr")


def method2():
    return browser \
        .find_element_by_id("host-panel") \
        .find_element_by_tag_name("table") \
        .find_element_by_tag_name("tbody") \
        .find_elements_by_tag_name("tr")


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
browser.get(LOGIN_URL)
if browser.current_url == LOGIN_URL and browser.title == "Log In - No-IP":
    browser.find_element_by_name("username").send_keys(email)
    browser.find_element_by_name("password").send_keys(password)
    browser.find_element_by_name("Login").click()
    sleep(2)

    if str(browser.current_url).startswith("https://my.noip.com/"):

        print("Login successful")

        browser.get(HOST_URL)
        # browser.save_screenshot("/home/photo0.png")
        sleep(1)

        aux = 1
        while browser.title != "My No-IP :: Hostnames" and aux < 3:
            browser.get(HOST_URL)
            # browser.save_screenshot("/home/photo0-" + str(aux) + ".png")
            sleep(3)
            aux += 1

        if browser.title.startswith("My No-IP :: Hostnames") and aux < 4:
            confirmed_hosts = 0

            # RENEW HOSTS
            try:
                hosts = method2()
                print("Confirming hosts phase")

                for host in hosts:
                    button = host.find_element_by_tag_name("button")
                    if button.text == "Confirm":
                        button.click()
                        confirmed_host = host.find_element_by_tag_name("a").text
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
