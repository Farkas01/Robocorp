*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Application
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.Robocorp.WorkItems
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order keyword here
    Download orders.csv
    Fill the form with the required data
    Make zip


*** Keywords ***
Open the robot order keyword here
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Accept rights
    Click Button    class:btn-dark

Download orders.csv
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Fill the form with the required data
    ${orders}    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Fill 1 line    ${order}
    END

Fill 1 line
    [Arguments]    ${order}
    Wait Until Page Contains Element    id:order
    Accept rights
    Select From List By Value    class:custom-select    ${order}[Head]
    Click Element    id:id-body-${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    id:address    ${order}[Address]
    Click Button    id:preview
    Wait Until Keyword Succeeds    10x    0.1sec    Send order
    recipe    ${order}

Send order
    Click Button    id:order
    Wait Until Page Contains Element    id:order-another

recipe
    [Arguments]    ${order}
    ${recipe}    Screenshot    id:receipt    ${OUTPUT_DIR}${/}${order}[Order number].png
    Html To Pdf    null    ${OUTPUT_DIR}${/}${order}[Order number].pdf
    Open Pdf    ${OUTPUT_DIR}${/}${order}[Order number].pdf
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}${order}[Order number].png
    ...    ${OUTPUT_DIR}${/}${order}[Order number].pdf

    Click Button    id:order-another

Make zip
    Archive Folder With Zip    ${OUTPUT_DIR}    orders.zip
