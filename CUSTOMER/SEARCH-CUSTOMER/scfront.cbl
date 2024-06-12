      ******************************************************************
      *    [MF-RD] Le programme affiche la SCREEN SECTION pour la      *
      *    recherche d'un adhérent et s'occupe des éventuels erreurs   *
      *    de saisi en affichant de nouveau la SCREEN SECTION avec le  *
      *    message d'erreur adéquat.                                   *
      ****************************************************************** 
       
       IDENTIFICATION DIVISION.
       PROGRAM-ID. scfront RECURSIVE.
       AUTHOR. Martial&Remi.

      ******************************************************************

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  SCREEN-CUSTOMER.
           05 SC-FIRSTNAME       PIC X(20).
           05 SC-LASTNAME        PIC X(20).
           05 SC-BIRTHDATE.   
               10 SCB-DAYS       PIC X(02).
               10 FILLER         PIC X(01) VALUE '-'.
               10 SCB-MONTH      PIC X(02).
               10 FILLER         PIC X(01) VALUE '-'.
               10 SCB-YEAR       PIC X(04).
           05 SC-CODE-SECU.    
               10 SCCS-SECU-1    PIC X(01).
               10 SCCS-SECU-2    PIC X(02).
               10 SCCS-SECU-3    PIC X(02).
               10 SCCS-SECU-4    PIC X(02).
               10 SCCS-SECU-5    PIC X(03).
               10 SCCS-SECU-6    PIC X(03).
               10 SCCS-SECU-7    PIC X(02).

       01  WS-CUSTOMER.
           03 WS-CUS-UUID        PIC X(36).
           03 WS-CUS-GENDER      PIC X(10).
           03 WS-CUS-LASTNAME    PIC X(20).
           03 WS-CUS-FIRSTNAME   PIC X(20).
           03 WS-CUS-ADRESS1	 PIC X(50).
           03 WS-CUS-ADRESS2	 PIC X(50).
           03 WS-CUS-ZIPCODE	 PIC X(15).
           03 WS-CUS-TOWN	     PIC X(50).
           03 WS-CUS-COUNTRY	 PIC X(20).
           03 WS-CUS-PHONE	     PIC X(10).
           03 WS-CUS-MAIL	     PIC X(50).
           03 WS-CUS-BIRTH-DATE  PIC X(10).
           03 WS-CUS-DOCTOR	     PIC X(50).
           03 WS-CUS-CODE-SECU   PIC 9(15).
           03 WS-CUS-CODE-IBAN   PIC X(34).
           03 WS-CUS-NBCHILDREN  PIC 9(03).
           03 WS-CUS-COUPLE      PIC X(05).
           03 WS-CUS-CREATE-DATE PIC X(10).
           03 WS-CUS-UPDATE-DATE PIC X(10).
           03 WS-CUS-CLOSE-DATE  PIC X(10).
           03 WS-CUS-ACTIVE	     PIC X(01).

       01  WS-MENU-RETURN        PIC X(01).
       01  WS-SEARCH-VALIDATION  PIC X(01).
       01  WS-ERROR-MESSAGE      PIC X(70).
       01  WS-CODE-REQUEST-SQL   PIC 9(01).

       SCREEN SECTION.
       COPY 'screen-search-customer.cpy'.

      ******************************************************************

       PROCEDURE DIVISION.
       0000-START-MAIN.
           INITIALIZE SCREEN-CUSTOMER
                      WS-MENU-RETURN
                      WS-SEARCH-VALIDATION
                      WS-ERROR-MESSAGE
                      WS-CODE-REQUEST-SQL.

           PERFORM 1000-START-SCREEN 
              THRU END-1000-SCREEN.
      
      *    [RD] Appel du BACK.
           CALL 
               'scback' 
               USING BY REFERENCE
               SCREEN-CUSTOMER, WS-CUSTOMER, WS-CODE-REQUEST-SQL
           END-CALL.

           PERFORM 2000-START-CUSTOMER-NOT-FOUND 
             THRU END-2000-CUSTOMER-NOT-FOUND.

      *    [RD] Appel le MENU D'ADHERENT.
           CALL 
               'menucust' 
               USING BY REFERENCE 
               WS-CUSTOMER
           END-CALL.
       END-0000-MAIN. 
           GOBACK.

      ******************************************************************
      *    [RD] Affiche l'écran de la recherche et appel les           *    
      *    paragraphes qui s'occupent de vérifier les saisis de        *
      *    l'utilisateur.                                              *
      ****************************************************************** 
       1000-START-SCREEN.
           ACCEPT SCREEN-SEARCH-CUSTOMER.
           
           PERFORM 1100-START-MENU-RETURN 
              THRU END-1100-MENU-RETURN.

           PERFORM 1200-START-SEARCH-VALIDATION
              THRU END-1200-SEARCH-VALIDATION.

           PERFORM 1300-START-ERROR-FIELDS 
              THRU END-1300-ERROR-FIELDS.
       END-1000-SCREEN.
           EXIT. 

      ******************************************************************
      *    [RD] Si l'utilisateur a saisi "O" sur "Retour au menu"      *
      *    redirige vers la fin de ce programme.                       *
      *    Si l'utilisateur a effectué une saisie incorrecte redirige  *
      *    vers le début de ce programme avec un message d'erreur.     *
      ******************************************************************
       1100-START-MENU-RETURN.
           MOVE FUNCTION UPPER-CASE(WS-MENU-RETURN) TO WS-MENU-RETURN.

           IF WS-MENU-RETURN EQUAL 'O' THEN
               CALL 
                   'manacust'
               END-CALL
           
           ELSE IF WS-MENU-RETURN NOT EQUAL 'O' 
               AND WS-MENU-RETURN NOT EQUAL SPACE THEN

               MOVE 'Veuillez entrer "O" pour retourner au menu.' 
               TO WS-ERROR-MESSAGE

               GO TO 1000-START-SCREEN
           END-IF.
       END-1100-MENU-RETURN.
           EXIT.

      ******************************************************************
      *    [RD] Si l'utilisateur n'a pas saisi "O" sur "Rechercher"    *
      *    redirige vers le début de ce programme.                     *
      ******************************************************************
       1200-START-SEARCH-VALIDATION.
           MOVE FUNCTION UPPER-CASE(WS-SEARCH-VALIDATION) 
           TO WS-SEARCH-VALIDATION.

           IF WS-SEARCH-VALIDATION NOT EQUAL 'O' THEN
               MOVE 'Veuillez entrer "O" pour rechercher.' 
               TO WS-ERROR-MESSAGE

               GO TO 1000-START-SCREEN
           END-IF.
       END-1200-SEARCH-VALIDATION.
           EXIT.

      ******************************************************************
      *    [RD] En fonction des champs remplis, attribu un chiffre à   *
      *    LK-CODE-REQUEST-SQL qui va servir à déterminer quelle       *
      *    requête SQL effectuer.                                      *
      *    Si aucune des conditions n'est remplies redirige vers le    *
      *    début de ce programme avec le message d'erreur adéquat.     *
      ******************************************************************
       1300-START-ERROR-FIELDS.
           IF SC-CODE-SECU IS NOT NUMERIC THEN
               STRING 
                   'Le numero de securite sociale ne doit contenir'
                   SPACE 'que des chiffres.'
                   DELIMITED BY SIZE
                   INTO WS-ERROR-MESSAGE
               END-STRING
               GO TO 1000-START-SCREEN
           END-IF.

           IF    SCB-DAYS  IS NOT NUMERIC 
              OR SCB-MONTH IS NOT NUMERIC
              OR SCB-YEAR  IS NOT NUMERIC
              THEN

               STRING 
                   'La date de naissance ne doit contenir'
                   SPACE 'que des chiffres.'
                   DELIMITED BY SIZE
                   INTO WS-ERROR-MESSAGE
               END-STRING
               GO TO 1000-START-SCREEN
           END-IF.
           
           IF     SC-CODE-SECU NOT EQUAL SPACES
              AND SC-FIRSTNAME     EQUAL SPACES
              AND SC-LASTNAME      EQUAL SPACES
              AND SCB-DAYS         EQUAL SPACES
              AND SCB-MONTH        EQUAL SPACES
              AND SCB-YEAR         EQUAL SPACES
              THEN
      
               SET WS-CODE-REQUEST-SQL TO 1
               GO TO END-1300-ERROR-FIELDS
           END-IF.

           IF     SC-CODE-SECU     EQUAL SPACES
              AND SC-FIRSTNAME NOT EQUAL SPACES
              AND SC-LASTNAME  NOT EQUAL SPACES
              AND SCB-DAYS     NOT EQUAL SPACES
              AND SCB-MONTH    NOT EQUAL SPACES
              AND SCB-YEAR     NOT EQUAL SPACES
              THEN

               SET WS-CODE-REQUEST-SQL TO 2
               GO TO END-1300-ERROR-FIELDS
           END-IF.

           IF     SC-CODE-SECU NOT EQUAL SPACES
              AND SC-FIRSTNAME NOT EQUAL SPACES
              AND SC-LASTNAME  NOT EQUAL SPACES
              AND SCB-DAYS     NOT EQUAL SPACES
              AND SCB-MONTH    NOT EQUAL SPACES
              AND SCB-YEAR     NOT EQUAL SPACES
              THEN

               SET WS-CODE-REQUEST-SQL TO 3
               GO TO END-1300-ERROR-FIELDS
           END-IF.

           MOVE "Erreur de saisie sur l'un des champs de la recherche."
           TO WS-ERROR-MESSAGE.
           GO TO 1000-START-SCREEN.
       END-1300-ERROR-FIELDS.
           EXIT.

      ******************************************************************
      *    [RD] Si la requête SQL du back n'a pas trouvé d'adhérent    *
      *    redirige vers le paragraphe qui affiche l'écran de recherche*
      *    avec le message d'erreur adéquat.                           *
      ****************************************************************** 
       2000-START-CUSTOMER-NOT-FOUND.
           IF WS-CUS-UUID EQUAL SPACES THEN
               MOVE "AUCUN ADHERENT TROUVE." TO WS-ERROR-MESSAGE
               GO TO 1000-START-SCREEN
           END-IF.
       END-2000-CUSTOMER-NOT-FOUND.
           EXIT.
