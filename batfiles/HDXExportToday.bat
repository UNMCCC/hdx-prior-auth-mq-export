sqlcmd -U username -Ppassword -S databaseservername -i C:\HDX\HDXExpressToday.sql -s";" -W  -h-1 -o \\AppLayerServerName\MOSAIQ_App\EXPORT\HDX\Upload\ELQ_UNMCC_TODAY_%date:~-4,4%_%date:~-10,2%_%date:~-7,2%.txt
