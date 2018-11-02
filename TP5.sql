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

/*4. Création d'un trigger qui vérifie que lors de la modification du salaire d’un infirmier,
 la nouvelle valeur ne peut jamais être inférieure à la précédente.*/

CREATE OR REPLACE TRIGGER Update_salaire 
	BEFORE UPDATE OF salaire ON infirmier 
  	FOR EACH ROW
BEGIN 
   	IF(:new.salaire < :old.salaire) THEN
   		raise_application_error(-20000,'ATTENTION LE NOUVEAU SALAIRE EST INFERIEUR A LANCIEN  MODIFICATION IMPOSSIBLE');
    END IF;
END;

UPDATE infirmier
SET salaire=0 WHERE num_inf=0;

/* 5 L’administrateur veut, pour un besoin interne, avoir le total des salaires infirmiers pour chaque service.
	 Pour cela, il ajoute un attribut : total_salaire_service dans la table service. */
ALTER TABLE service ADD total_salaire float DEFAULT 0 ;
UPDATE service S
SET total_salaire=(SELECT SUM(salaire) FROM infirmier I WHERE I.code_service=S.code_service);

CREATE OR REPLACE TRIGGER TotalSalaire_Serivce_trigger
	AFTER INSERT ON infirmier 
	FOR EACH ROW
BEGIN
	UPDATE service S
	SET total_salaire= total_salaire+:new.salaire WHERE S.code_service=:new.code_service;
END;
INSERT INTO infirmier VALUES(0,'CAR','JOUR',1000);

CREATE OR REPLACE TRIGGER TotalSalaireUpdate_trigger
	AFTER UPDATE ON infirmier 
	FOR EACH ROW
BEGIN
	UPDATE service S
	SET total_salaire= total_salaire-:old.salaire+:new.salaire WHERE S.code_service=:new.code_service;
END;
UPDATE infirmier
SET salaire=3000 WHERE num_inf=0;

/* 6 Création un trigger qui mit à jour l’attribut total_salaire_service des deux services.*/
CREATE OR REPLACE TRIGGER total_salaire_service
 	AFTER UPDATE OF code_service ON infirmier
 	FOR EACH ROW
BEGIN
	UPDATE service S
	SET total_salaire=total_salaire-:old.salaire WHERE S.code_service=:old.code_service;
	UPDATE service S
	SET total_salaire=total_salaire+:new.salaire WHERE S.code_service=:new.code_service;
END;
UPDATE infirmier
SET code_service='CHG' WHERE num_inf=0; 

/* 7 L’administrateur veut sauvegarder toutes les hospitalisations des patients dans le temps.*/
CREATE TABLE Hist_Hospit (
	date_hospit date,
	num_patient integer,
	code_service varchar(10),
	CONSTRAINT pk_hist_hospit PRIMARY KEY (date_hospit,num_patient,code_service),
	CONSTRAINT fk_pathost FOREIGN KEY (num_patient) REFERENCES patient (num_patient),
	CONSTRAINT fk_serhost FOREIGN KEY (code_service) REFERENCES service (code_service)
);
CREATE OR REPLACE TRIGGER Host
	AFTER INSERT ON hospitalisation
	FOR EACH ROW
BEGIN
	INSERT INTO Hist_Hospit VALUES(:new.date_host,:new.num_patient,:new.code_service);
END;

INSERT INTO hospitalisation VALUES (13,'CAR',101,1,'02/11/2018');

/* FIN /