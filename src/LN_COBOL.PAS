Program Ln_Cobol;            { mise … jour : 19 - 01 - 1991 }

{
Titre : Numerateur de fichiers Cobol.

Auteur: Pr‚martin Patrick.
Date de la premiŠre version: 1 janvier 1991.

Cet utilitaire num‚rote les lignes des fichiers sources en Cobol.
}

Uses Crt,
     u_Sgf,
     u_aff_Chaine,
     olf_software,
     u_Fenetre;

Const
     Date_Version : String [10] = '19-01-1991';
      Num_Version  : String [3]  = '1.1';
      Ctrl_Z                     = #$1A;       { =17 code de fin de fichier }

Var Sortie : Boolean;

Procedure Attente_Appuit_Touche;
Var Carac        : Char;
    Old_Textattr : Integer;
Begin { attente_appuit_touche }
  Old_Textattr := Textattr;
  Textcolor (White);
  Textbackground (Black);
  Affic_Center ('Appuyez sur une touche...');
  While (Keypressed) Do Carac := Readkey;
  Carac := Readkey;
  Textattr := Old_Textattr;
  Gotoxy (1, Wherey);
  Clreol
End; { attente_appuit_touche }

Procedure Presentation;
Begin { presentation }
  Type_Cadre := 5;
  Window_Cadre_Bis (2, 2, 79, 9, Brown, Blue);
  Window_Titre ('Num‚rateur de fichiers COBOL.', Lightblue+Blink, Red);
  Textcolor (White);
  Textbackground (Green);
  Clrscr;
  Affic_Center_Ln ('Auteur: Pr‚martin Patrick');
  Affic_Center_Ln (Concat ('Version ', Num_Version));
  Affic_Center_Ln (Concat ('Date ', Date_Version));
  Writeln;
  Writeln  ('   Ce programme permet de num‚roter les fichiers sources en Cobol. Il indique');
  Writeln ('le num‚ro de la ligne courante dans la marge qui pr‚cŠde la colonne 7.');
  Writeln;
  Attente_Appuit_Touche;
  Clear_Window
End; { presentation }

Procedure Ask_Nom_Fichier (Var Nom_Fichier : String);
Var Nom_Fic : String;
Begin { ask_nom_fichier }
  Type_Cadre := 10;
  Window_Cadre_Bis (2, 2, 79, 3, Lightblue, Blue);
  Window_Titre (Concat ('Nom par d‚faut: ', Nom_Fichier), White, Red);
  Nom_Fic := '';
  Repeat
    Clrscr;
    If (Nom_Fic <> '')
    Then
      Affic_Center_Ln (Concat (Nom_Fic, ' n''existe pas.'))
    {endif};
    Readln (Nom_Fic);
    Met_Extension (Nom_Fic, '.CBL', Nom_Fic)
  Until ((Nom_Fic = '.CBL') Or (Exist (Nom_Fic)));
  If (Nom_Fic <> '.CBL')
  Then
    Nom_Fichier := Nom_Fic
  {endif};
  Clear_Window
End; { ask_nom_fichier }

Procedure Message_Alerte (Message : String; Waiting : Boolean);
Begin { message_alerte }
  Clear_Window;
  Type_Cadre := 4;
  Window_Cadre_Bis (2, 2, 79, 2, Red, Blue);
  Window_Titre (Message, White, Blue);
  Clrscr;
  If (Waiting)
  Then
    Begin
      Attente_Appuit_Touche;
      Clear_Window
    End
  {endif}
End; { message_alerte }

Procedure Modif_Prog (Nom_Fich1 : String);
Var Nom_Fich2,
    Chaine     : String;
    Num_Ligne  : Integer;
    Bug        : Boolean;
    Fichier1,              { fichier contenant les ordres de linkage }
    Fichier2   : Text;     { fichier destination                     }
Begin { modif_prog }
  If (Exist (Nom_Fich1))
  Then
    Begin
      Message_Alerte ('Traitement en cours...', False);
      Met_Extension (Nom_Fich1, '.$$$', Nom_Fich2);
      Assign (Fichier1, Nom_Fich1);
      Reset (Fichier1);
      Assign (Fichier2, Nom_Fich2);
      Rewrite (Fichier2);
      Num_Ligne := 0;
      While Not (Eof (Fichier1)) Do
        Begin
          Inc (Num_Ligne);
          Gotoxy (1, 1);
          Write ('Ligne en cours: ',Num_Ligne);
          Clreol;
          Readln (Fichier1, Chaine);
          Writeln (Fichier2, Num_Ligne:5, ' ', Copy (Chaine, 7, Length (Chaine)-6))
        End
      {endwhile};
      Gotoxy (1, 1);
      Write ('Cr‚ation du fichier .BAK');
      Clreol;
      Close (Fichier1);
      Writeln (Fichier2, Ctrl_Z);
      Close (Fichier2);
      Cree_Bak (Nom_Fich1);
      Bug := Efface (Nom_Fich1);
      Bug := Renomme (Nom_Fich2, Nom_Fich1);
      Message_Alerte ('Fin du traitement...', True)
    End
  Else
    Message_Alerte (Concat (Nom_Fich1, ' n''existe pas.'), True)
  {endif}
End; { modif_prog }

Function Ask_Recommencer: Boolean;
Var Carac : Char;
Begin { ask_recommencer }
  Type_Cadre := 10;
  Window_Cadre_Bis (5, 10, 75, 10, Blue, Green);
  Window_Titre ('Voulez-vous faire un autre fichier ?', Black, Lightgray);
  Textcolor (White);
  Textbackground (Black);
  Clrscr;
  Affic_Center ('Votre choix ? (Oui / Non) ');
  Repeat
    Carac := Upcase (Readkey);
    Write (Carac);
    Gotoxy (Pred (Wherex), Wherey)
  Until (Carac In ['O', 'N']);
  Clear_Window;
  Ask_Recommencer := (Carac = 'O')
End; { ask_recommencer }

Procedure Traitement;
Var Nom_Fichier : String;
Begin { traitement }
  Nom_Fichier := 'NONAME.CBL';
  Repeat
    Ask_Nom_Fichier (Nom_Fichier);
    Modif_Prog (Nom_Fichier)
  Until Not (Ask_Recommencer)
End; { traitement }

Begin { ln_cobol }
      init_olf_message (mess_freeware);
      init_licence ('LNCO');
      init_olf_software ('Liner Cobol '+num_version, #155' Patrick Pr‚martin '+date_version);
  Reset_screen;
  Presentation;
  Traitement;
  Reset_screen
End. { ln_cobol }
