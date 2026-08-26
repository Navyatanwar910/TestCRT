*** Settings ***
Documentation           New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                 QForce
Library    QWeb
Library    DateTime    # Required for timestamp generation
Suite Setup             Open Browser    https://gsbexeced--full.sandbox.lightning.force.com    chrome
Suite Teardown          Close All Browsers


*** Variables ***
# Default Common Card Fields (Stripe accepts any future date & valid CVC length)
${DEFAULT_EXP_DATE}    12/34
${DEFAULT_CVC}         123
${AMEX_CVC}            1234
${DEFAULT_ZIP}         12345

# -----------------------------------------------------------------------------
# STRIPE TEST CARDS DATASET (https://docs.stripe.com/testing)
# -----------------------------------------------------------------------------

# --- Standard Success Cards ---
${CARD_VISA_SUCCESS}               4242424242424242
${CARD_VISA_DEBIT}                 4000056655665556
${CARD_MASTERCARD}                 5555555555554444
${CARD_MASTERCARD_DEBIT}           5200828282828210
${CARD_AMEX}                       378282246310005
${CARD_DISCOVER}                   6011111111111117
${CARD_JCB}                        3566002020360505
${CARD_DINERS}                     3056930009020004
${CARD_UNIONPAY}                   6200000000000005

# --- Decline & Error Scenarios ---
${CARD_DECLINE_GENERIC}            4000000000000002
${CARD_DECLINE_INSUFFICIENT_FUNDS} 4000000000009995
${CARD_DECLINE_LOST}               4000000000009987
${CARD_DECLINE_STOLEN}             4000000000009979
${CARD_DECLINE_EXPIRED}            4000000000000069
${CARD_DECLINE_INCORRECT_CVC}      4000000000000127
${CARD_DECLINE_PROCESSING_ERROR}   4000000000000119
${CARD_DECLINE_FRAUDULENT}         4100000000000019

# --- 3D Secure (3DS) Authentication Cards ---
${CARD_3DS_REQUIRED}               4000002760003184
${CARD_3DS2_CHALLENGE}             4000000000003220

# --- Country-Specific Cards ---
${CARD_INDIA_VISA}                 4000003560000008
${CARD_JAPAN_VISA}                 4000003920000003
${CARD_MEXICO_VISA}                4000004840008001



*** Test Cases ***   
Login To Salesforce Instance
    OpenBrowser    ${login_url}    chrome
    VerifyText    Salesforce login
    TypeText      Username         ${username_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Password
    TypeSecret    Password    ${password_Admin}
    ClickText     Log In to Sandbox
    VerifyText    Verify Your Identity
    TypeText      Verification Code    MTQGAWBDPC
    ClickText     Verify
    VerifyText    Home
    ClickText     Programs             anchor=Home
    ClickText     ACR-20260820-132926 - December 2026
    ClickText     PayExed              anchor=Enrollment
    ClickText     ACR-20260820-13-R6605
    Sleep              5s
    ClickElement       xpath=//a[contains(@href,'pay')]
    SwitchWindow       NEW
    ClickText          Make Payment
    ClickText          Payment Amount (USD)
    TypeText           Payment Amount (USD)          25000
    TypeText           Card number                   4242
    TypeText           Expiration date               10/29
    TypeText           Security code                 123
    ClickText          PAY NOW
