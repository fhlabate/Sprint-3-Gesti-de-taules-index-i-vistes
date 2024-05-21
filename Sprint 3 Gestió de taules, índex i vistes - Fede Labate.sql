-- Tasca S3.01. "Manipulació de taules"

-- ####### Nivell 1 #######
-- Exercici 1
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
CREATE TABLE credit_card (
    id VARCHAR(255) PRIMARY KEY NOT NULL,
    iban VARCHAR(255) NULL,
    pan VARCHAR(255) NULL,
    pin VARCHAR(255) NULL,
    cvv VARCHAR(255) NULL,
    expiring_date VARCHAR(255) NULL
);

## Redefinición de tipos de variables en la tabla credit_card:
#id -> Cambio a VARCHAR(8)
ALTER TABLE credit_card MODIFY id VARCHAR(8) NOT NULL;
#iban -> Utilizo VARCHAR(32)caracteres dado que es la cantidad de los IBANs más largos del mundo (Santa Lucia & Nicaragua). Fuente: https://es.iban.com/estructura
ALTER TABLE credit_card MODIFY iban VARCHAR(32);
#pan -> 19 caracteres era suficiente pero coloco VARCHAR(20) por seguridad (No coloco INT por los espacios).
ALTER TABLE credit_card MODIFY pan VARCHAR(20);
#pin -> Número de 4 cifras -> SMALLINT: Enteros de -32768 a 32767.
ALTER TABLE credit_card MODIFY pin SMALLINT;
#cvv -> Número de 3 cifras -> SMALLINT: Enteros de -32768 a 32767.
ALTER TABLE credit_card MODIFY cvv SMALLINT;
#expiring_date -> Tipo DATE previa transformación:
## Paso 1: Añadir una nueva columna de tipo DATE.
ALTER TABLE credit_card
ADD COLUMN expiring_date_new DATE;
## Paso 2: Actualizar los valores del nuevo campo. [%m: Mes (01-12)] | [%d: Día del mes (01-31)] | [%Y: Año con cuatro dígitos]
UPDATE credit_card
SET expiring_date_new = STR_TO_DATE(expiring_date, "%m/%d/%Y"); 
## Paso 3: Eliminar el campo original (expiring_date).
ALTER TABLE credit_card
DROP COLUMN expiring_date;
## Paso 4: Cambio el nombre de la columna nuevamente a expiring_date
ALTER TABLE credit_card CHANGE expiring_date_new expiring_date DATE;

#Vinculación de transaction.credit_card_id con credit_card.id:
## Cambio el tipo de dato para que sean iguales: VARCHAR(8)
ALTER TABLE transaction CHANGE credit_card_id credit_card_id VARCHAR(8) NOT NULL;
## Creo la Foreing Key:
ALTER TABLE transaction 
ADD CONSTRAINT fk_transaction_credit_card 
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id);

-- Visualizo el total de las columnas con sus Types correctos.
SHOW COLUMNS FROM transaction;
SHOW COLUMNS FROM credit_card;
SHOW COLUMNS FROM company;

-- Exercici 2
-- El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. 
-- La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
#Consulta inicial:
SELECT * 
FROM credit_card
WHERE id = "CcU-2938";
#Cambio:
UPDATE credit_card set
iban = 'R323456312213576817699999'
WHERE id = "CcU-2938";
#Confirmación del cambio:
SELECT * 
FROM credit_card
WHERE id = "CcU-2938";

-- Exercici 3
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:
-- Id: 108B1D1D-5B23-A76C-55EF-C568E49A99DD | credit_card_id: CcU-9999 | company_id: b-9999 | user_id: 9999 | lat: 829.999 | longitude: -117.999 | amount: 111.11 | declined: 0 |
SELECT * FROM company WHERE id = "b-9999";
#Debo crear primero los registros company.id = "b-9999" y credit_card.id="CcU-9999" por ser claves externas a la tabla transaction:
INSERT INTO company (id)
VALUES ("b-9999");
INSERT INTO credit_card (id)
VALUES ("CcU-9999");
#Creo el nuevo usuario
insert into transaction(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
values ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", "829.999", "-117.999", "111.11", "0");
#Visualizo la nueva transacción
SELECT * FROM transaction
WHERE id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD";

-- Exercici 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. 
-- Recorda mostrar el canvi realitzat.
#Elimino campo pan
ALTER TABLE credit_card
DROP COLUMN pan;
#Visualizo la tabla credit_card
SHOW COLUMNS
FROM credit_card;

-- ####### Nivell 2 #######
-- Exercici 1
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.
DELETE
FROM transaction 
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";
#Visualizo el id eliminado.
SELECT * FROM transaction WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- Exercici 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
-- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
#Creación de la vista "VistaMarketing"
CREATE VIEW VistaMarketing AS (
								SELECT c.company_name AS "Nom", c.phone AS "Telefon", c.country AS "Pais", ROUND(AVG(t.amount),2) AS "MitjanaDeCompra"
								FROM company c
								JOIN transaction t
								ON c.id = t.company_id
								WHERE t.declined = 0
								GROUP BY c.id
                                );
#Visualización 
SELECT *
FROM VistaMarketing
ORDER BY MitjanaDeCompra DESC;

-- Exercici 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
SELECT *
FROM VistaMarketing
WHERE Pais = "Germany";

-- ####### Nivell 3 #######
-- Exercici 1
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama ER (Ver PDF).
-- Recordatori: En aquesta activitat, és necessari que descriguis el "pas a pas" de les tasques realitzades. És important realitzar descripcions senzilles, simples i fàcils de comprendre. Per a realitzar aquesta activitat hauràs de treballar amb els arxius denominats "estructura_dades_user" i "dades_introduir_user".
#Inserto estructura_datoss_user.sql y datos_introducir_user (1).sql
-- Open SQL Scrip... (Ctrl+Mayus+o) > estructura_datoss_user.sql & datos_introducir_user (1).sql
#Visualizo el diagrama E/R actual con el Reverse Enginer (Ctrl + R)
-- Diagrama ER actual
#Procedo a hacer los cambios marcados en rojo. (Ver PDF)

##Tabla company: 
#Eliminar campo "website"
ALTER TABLE company DROP COLUMN website;
#Visualización
SHOW COLUMNS 
FROM company;

##Tabla data_user: 
#Renombrar el campo email por personal_email
RENAME TABLE user TO data_user;
#Visualización
SHOW tables;

##Tabla data_user: 
#Renombrar el campo email por personal_email
ALTER TABLE data_user CHANGE email personal_email VARCHAR(150);
#Visualización
SHOW COLUMNS 
FROM data_user;

##Tabla data_user: 
#Invertir la relación de la FK user.id de la tabla transaction.
-- Para ello debo averiguar el nombre de la FK existente, eliminarla y luego crear una nueva desde transaction hacia data_user 
SHOW CREATE TABLE data_user;
#Eliminar la FK data_user_ibfk_1
ALTER TABLE data_user DROP FOREIGN KEY data_user_ibfk_1;

##Tabla transaction:
#Cambiar credit_card_id de NOT NULL a que permita valores nulos y que el tipo de dato sea VARCHAR(15)
ALTER TABLE transaction CHANGE credit_card_id credit_card_id VARCHAR (15);
#Visualización
SHOW COLUMNS 
FROM transaction;

#Eliminar la Foreign Key fk_transaction_credit_card
ALTER TABLE transaction DROP FOREIGN KEY fk_transaction_credit_card;

##Tabla credit_card:
#Cambiar el tipo de los siguientes campos:
-- id a VARCHAR(20) | iban a VARCHAR(50) | pin a VARCHAR(4) | cvv a INT |  expiring_date a VARCHAR (10).
ALTER TABLE credit_card MODIFY COLUMN id VARCHAR(20);
ALTER TABLE credit_card MODIFY COLUMN iban VARCHAR(50);
ALTER TABLE credit_card MODIFY COLUMN pin VARCHAR(4);
ALTER TABLE credit_card MODIFY COLUMN cvv INT;
ALTER TABLE credit_card MODIFY COLUMN expiring_date VARCHAR(10);
-- Eliminar el campo pan. 
ALTER TABLE credit_card DROP COLUMN pan;
-- Agrego el campo fecha_actual con tipo DATE
ALTER TABLE credit_card ADD fecha_actual DATE;
#Visualización:
SHOW COLUMNS 
FROM credit_card;

#Foreign Keys
-- Agregar FK: transaction -> credit_card (N a 1)
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card (id);

-- Agregar FK: transaction -> data_user (N a 1)
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_data_user
FOREIGN KEY (user_id)
REFERENCES data_user (id);

-- Cambiar nombre transaction_ibfk_1 a fk_transaction_company
#Eliminar transaction_ibfk_1
ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_1;
#Crearla nuevamente con el nombre fk_transaction_company
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_company
FOREIGN KEY (company_id)
REFERENCES company (id);

-- Exercici 2
-- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
-- 	ID de la transacció
-- 	Nom de l'usuari/ària
-- 	Cognom de l'usuari/ària
-- 	IBAN de la targeta de crèdit usada.
-- 	Nom de la companyia de la transacció realitzada.
-- Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
-- Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.
#Creación de la vista informeTecnico
CREATE VIEW informeTecnico AS
							(
                            SELECT t.id as "IdTransaccio", du.name as "NomUsuari", du.surname AS "CognomUsuari", cc.iban AS "IBAN", c.company_name AS "Companyia"
                            FROM transaction t
                            JOIN data_user du
                            ON t.user_id = du.id
                            JOIN credit_card cc
                            ON t.credit_card_id = cc.id
                            JOIN company c
                            ON t.company_id = c.id
                            );
#Visualización
SELECT *
FROM InformeTecnico
ORDER BY IdTransaccio DESC;