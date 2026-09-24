Code snippet
*** Settings ***
Documentation       Process Payment in Salesforce and Issue Refund via Stripe Dashboard
Library             QWeb

*** Variables ***
${login_url}    https://gsbexeced--full.sandbox.my.salesforce.com/
${username_Admin}    navya799@stanford.edu
${password_Admin}    GreenOrangeKiwi@123
${CARD_NUMBER}          41414141414141
${CARD_EXP}             1228
${CARD_CVC}             123

# Stripe Dashboard Config
${STRIPE_URL}           https://dashboard.stripe.com/login
${STRIPE_USER}          Kota1234@stanford.edu
${STRIPE_PASS}          Salesforce@1234

*** Test Cases ***
Create Transaction In Salesforce And Refund In Stripe
    [Documentation]    Executes end-to-end payment creation in Salesforce and processes refund in Stripe.
    OpenBrowser        ${login_url}        chrome
    VerifyText         Salesforce login
    TypeText           Username            ${username_Admin}
    ClickText          Log In to Sandbox
    VerifyText         Password
    TypeSecret         Password            ${password_Admin}
    ClickText          Log In to Sandbox
    VerifyText         Verify Your Identity
    TypeText           Verification Code   QGVVMJMA4G
    ClickText          Verify
    VerifyText         Home
    ClickText          Programs            anchor=Home
    ClickText     ACR-20260902-16-R6640    anchor=Navya K. Tanwar
    SwitchWindow                        NEW
    VerifyText                        Invoice Status                  timeout=10s
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText         Make Payment
    ClickText          Payment Amount (USD)
    TypeText           Payment Amount (USD)    100
    TypeText           Card number             ${CARD_NUMBER}
    TypeText           Expiration date         ${CARD_EXP}
    TypeText           Security code           ${CARD_CVC}
    ClickText          PAY NOW