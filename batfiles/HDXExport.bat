sqlcmd -U username -P password -S databaseserver -i C:\HDX\HDXExpressDaily.sql -s";" -W  -h-1 -o \\AppLayerServerName\MOSAIQ_App\EXPORT\HDX\Upload\ELQ_UNMCC%date:~-4,4%_%date:~-10,2%_%date:~-7,2%.txt
