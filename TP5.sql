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

/*MAJ*/
CREATE OR REPLACE TRIGGER MAJ
AFTER INSERT OR UPDATE OR DELETE ON INFIRMIER FOR EACH ROW
BEGIN
	IF(INSERTING) THEN		
		dbms_output.put_line('un nouveau employé de type infirmier est ajouté');
	END IF;
	IF(UPDATING) THEN
		dbms_output.put_line('un employé de type infirmier modifié');
	END IF;
	IF(DELETING) THEN
		dbms_output.put_line('Infirmier supprimé');
	END IF;
END; 


/* 2 Creation d'un trigger qui affiche « un nouveau infirmier est affecté à un [Nom de service] »
 après chaque insertion d’un infirmier.*/
CREATE OR REPLACE TRIGGER Affectation_inf
AFTER INSERT
   ON infirmier
   FOR EACH ROW
BEGIN 
	dbms_output.put_line('un nouveau infirmier est affecté a '||:new.code_service);
END;
insert into infirmier values(0,'CAR','JOUR',4780);

/* 3 Création d'un triggers qui vérifie avant modification du code service 
dans la table infirmier que la nouvelle valeur existe réellement, sinon, il refuse l’opération.*/
/*ALTER TABLE INFIRMIER DISABLE CONSTRAINT FK_SERVICEINF;*/

CREATE OR REPLACE TRIGGER update_Service
BEFORE UPDATE OF code_service
   	ON infirmier
	FOR EACH ROW
        DECLARE
    ICS infirmier.code_service%type;
BEGIN
   	SELECT code_service into ICS FROM service WHERE code_service = :new.code_service ;
   	EXCEPTION WHEN NO_DATA_FOUND THEN
        raise_application_error(-20000,'ERREUR LE CODE SERVICE NEXISTE PAS DANS LA TABLE SERVICE'); 
END;
UPDATE infirmier 
SET code_service='XXX' WHERE num_inf=0;
