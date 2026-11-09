// Abfrage: Events_real
// Reale Bearbeitungsschritte aus den Rückmeldungen, mit Sortier-Priorität je Aktivitätsklasse.
// Quelle "Tabelle92" = zusammengeführte API-Rohdaten im Excel-Workbook.

Events_real = let
    Quelle = Excel.CurrentWorkbook(){[Name="Tabelle92"]}[Content],
    #"Umbenannte Spalten" = Table.RenameColumns(Quelle,{{"requested_datetime", "Ticket eingegangen"}, {"updated_datetime", "letztes Ticketupdate"}}),
    #"Umbenannte Spalten1" = Table.RenameColumns(#"Umbenannte Spalten",{{"status_notes", "Aktivität Text Mitarbeiter"}, {"datetime", "Zeitstempel"}}),
    #"Hinzugefügte benutzerdefinierte Spalte" = Table.AddColumn(#"Umbenannte Spalten1", "Aktivität", each
        /* Aktivitäts-Mapping: siehe 01_aktivitaets_mapping.m */ ...),
    #"Entfernte Spalten2" = Table.RemoveColumns(#"Hinzugefügte benutzerdefinierte Spalte",{"description", "Ticket eingegangen", "letztes Ticketupdate", "address"}),
    #"Neu angeordnete Spalten" = Table.ReorderColumns(#"Entfernte Spalten2",{"service_request_id", "Zeitstempel", "service_name", "zipcode", "lat", "long", "title", "Aktivität Text Mitarbeiter", "Aktivität"}),
    #"Entfernte Spalten3" = Table.RemoveColumns(#"Neu angeordnete Spalten",{"Aktivität Text Mitarbeiter"}),
    #"Hinzugefügte benutzerdefinierte Spalte1" = Table.AddColumn(#"Entfernte Spalten3", "Synthethisch erstellt", each 0),
    #"Umbenannte Spalten2" = Table.RenameColumns(#"Hinzugefügte benutzerdefinierte Spalte1",{{"service_request_id", "Case_ID"}}),
    #"Gefilterte Zeilen" = Table.SelectRows(#"Umbenannte Spalten2", each [Zeitstempel] <> null and [Zeitstempel] <> ""),
    #"Geänderter Typ" = Table.TransformColumnTypes(#"Gefilterte Zeilen",{{"Zeitstempel", type datetimezone}}),
    #"Entfernte Spalten" = Table.RemoveColumns(#"Geänderter Typ",{"status_name"}),
    #"Hinzugefügte benutzerdefinierte Spalte2" = Table.AddColumn(#"Entfernte Spalten", "AktivitätenPriorität", each if [Aktivität] = "Eingangsbestätigung" then 10
else if [Aktivität] = "Weitergeleitet" then 20
else if [Aktivität] = "Rückfrage / unklare Meldung" then 30
else if [Aktivität] = "Verzögerung / Kapazitätshinweis" then 40
else if [Aktivität] = "Turnus / regelmäßige Maßnahme" then 50
else if [Aktivität] = "In Bearbeitung / Prüfung / Planung" then 60
else if [Aktivität] = "Nicht möglich / noch zeitliche Abstimmung" then 70
else if [Aktivität] = "Behoben / Erledigt" then 80
else if [Aktivität] = "Bereits bekannt / Doppelmeldung" then 85
else if [Aktivität] = "Nicht zuständig" then 90
else if [Aktivität] = "Noch nicht bearbeitet" then 95
else 96),
    #"Umbenannte Spalten3" = Table.RenameColumns(#"Hinzugefügte benutzerdefinierte Spalte2",{{"Synthethisch erstellt", "Synthetisch erstellt"}})
in
    #"Umbenannte Spalten3"
