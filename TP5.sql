/*1 Creation des triggers de mise a jour sur la table infirmier*/
/*Insertion*/
CREATE OR REPLACE TRIGGER insert_inf
AFTER INSERT
   ON infirmier
   FOR EACH ROW
BEGIN 
	dbms_output.put_line('un nouveau employé de type infirmier est ajouté');
END;
insert into employe values(0,'nasser','zek','deles','256666666');
insert into infirmier values(0,'CAR','JOUR',4780);

/*Update*/
CREATE OR REPLACE TRIGGER update_inf
AFTER UPDATE
   ON infirmier
   FOR EACH ROW
BEGIN 
	dbms_output.put_line('un employé de type infirmier modifié');
END;
update infirmier set 
salaire=5124 where num_inf=0;

/*Delete*/
CREATE OR REPLACE TRIGGER delete_inf
AFTER DELETE
   ON infirmier
   FOR EACH ROW
BEGIN 
	dbms_output.put_line('Infirmier supprimé');
END;
delete from infirmier where num_inf=0;

/*Creation d'un trigger qui affiche « un nouveau infirmier est affecté à un [Nom de service] » après chaque insertion d’un infirmier.*/
CREATE OR REPLACE TRIGGER Affectation_inf
AFTER INSERT
   ON infirmier
   FOR EACH ROW
BEGIN 
	dbms_output.put_line('un nouveau infirmier est affecté a '||:new.code_service);
END;
insert into infirmier values(0,'CAR','JOUR',4780);
