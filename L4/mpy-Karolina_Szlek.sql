-- Karolina Szlęk, grupa MPY

-- Zadanie 1


ALTER TABLE comments ADD COLUMN lasteditdate timestamp NOT NULL DEFAULT now();

CREATE OR REPLACE FUNCTION ins_to_lasteditdate() RETURNS VOID AS
$X$ 
	DECLARE creation timestamp;
    		cr_id int;
        BEGIN 
    	FOR cr_id IN SELECT id FROM comments
        LOOP
            SELECT creationdate INTO creation
            FROM comments
            WHERE id = cr_id;
            
            UPDATE comments
            SET lasteditdate = creation
            WHERE id = cr_id;
		END LOOP;
	END
$X$ LANGUAGE 'plpgsql';   

SELECT ins_to_lasteditdate();

CREATE TABLE commenthistory(
    id SERIAL PRIMARY KEY,
    commentid integer,
    creationdate timestamp, 
    text text);


-- Zadanie 2


CREATE OR REPLACE FUNCTION wyzwalacz1() RETURNS TRIGGER AS $$
    BEGIN
        NEW.creationdate := OLD.creationdate;
	IF NEW.id <> OLD.id OR NEW.postid <> OLD.postid OR NEW.lasteditdate <> OLD.lasteditdate THEN
		RAISE EXCEPTION 'Proszę nie zmianiac kolumn';
	END IF;

	IF NEW.text <> OLD.text THEN
		NEW.lasteditdate := now();
		INSERT INTO commenthistory (commentid, creationdate,text) VALUES (OLD.id, OLD.lasteditdate, OLD.text);
	END IF;
	RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER uzupelnienie_danych
BEFORE UPDATE 
    ON comments
   FOR EACH ROW
EXECUTE PROCEDURE wyzwalacz1();


-- Zadanie 3


CREATE OR REPLACE FUNCTION wyzwalacz2() RETURNS TRIGGER AS $$
    BEGIN
        NEW.lasteditdate := NEW.creationdate;
	RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER name1
BEFORE INSERT 
    ON comments
   FOR EACH ROW
EXECUTE PROCEDURE wyzwalacz2();




