// Abfrage: Cleaned_Daten
// Bereinigung: Spalten umbenannt, Zeitstempel als datetimezone, Kennzahlen Ticketdauer und Dauer bis zur Bearbeitung.
// Quelle "Tabelle92" = zusammengeführte API-Rohdaten im Excel-Workbook.

Cleaned_Daten = let
    Quelle = Excel.CurrentWorkbook(){[Name="Tabelle92"]}[Content],
    #"Umbenannte Spalten" = Table.RenameColumns(Quelle,{{"requested_datetime", "Ticket eingegangen"}, {"updated_datetime", "letztes Ticketupdate"}}),
    #"Umbenannte Spalten1" = Table.RenameColumns(#"Umbenannte Spalten",{{"status_notes", "Aktivität Text Mitarbeiter"}, {"datetime", "Zeitstempel"}}),
    #"Hinzugefügte benutzerdefinierte Spalte" = Table.AddColumn(#"Umbenannte Spalten1", "Aktivität", each
        /* Aktivitäts-Mapping: siehe 01_aktivitaets_mapping.m */ ...),
    #"Geänderter Typ" = Table.TransformColumnTypes(#"Hinzugefügte benutzerdefinierte Spalte",{{"Ticket eingegangen", type datetimezone}, {"letztes Ticketupdate", type datetimezone}, {"Zeitstempel", type datetimezone}}),
    #"Hinzugefügte benutzerdefinierte Spalte1" = Table.AddColumn(#"Geänderter Typ", "Ticketdauer_Tage", each Duration.TotalDays([letztes Ticketupdate] - [Ticket eingegangen])),
    #"Hinzugefügte benutzerdefinierte Spalte2" = Table.AddColumn(#"Hinzugefügte benutzerdefinierte Spalte1", "Dauer bis zur Bearbeitung", each Duration.TotalDays([Zeitstempel] - [Ticket eingegangen]))
in
    #"Hinzugefügte benutzerdefinierte Spalte2"
