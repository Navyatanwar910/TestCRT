Code snippet
*** Settings ***
Documentation       Process Payment in Salesforce and Issue Refund via Stripe Dashboard
Library             QWeb

*** Variables ***
${login_url}
${username_Admin}
${password_Admin}
${INVOICE_ID}           ACR-20260902-16-R6640
${CARD_NUMBER}          4242424242424242
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
    TypeText           Verification Code   11KLAYEG2L
    ClickText          Verify
    VerifyText         Home
    ClickText          Programs            anchor=Home