CREATE PROCEDURE ComputeAverageWeightedScoreForUsers()
BEGIN
  DECLARE sum_scores DECIMAL(10,2) DEFAULT 0;
  DECLARE sum_weights INT DEFAULT 0;
  
  -- Loop through all users
  DECLARE user_cursor CURSOR FOR
    SELECT id, COUNT(*) AS corrections_count
    FROM users u
    INNER JOIN corrections c ON u.id = c.user_id;
  DECLARE user_row RECORD(id INT, corrections_count INT);
  
  OPEN user_cursor;
  LOOP
    FETCH user_cursor INTO user_row;
    IF NOT FOUND THEN LEAVE LOOP; END IF;
    
    -- Calculate sum of scores and weights for each user
    SET sum_scores = 0;
    SET sum_weights = 0;
    
    DECLARE correction_cursor CURSOR FOR
      SELECT project_id, score, weight
      FROM corrections c
      INNER JOIN projects p ON c.project_id = p.id
      WHERE c.user_id = user_row.id;
    DECLARE correction_row RECORD(project_id INT, score DECIMAL(10,2), weight INT);
    
    OPEN correction_cursor;
    LOOP
      FETCH correction_cursor INTO correction_row;
      IF NOT FOUND THEN LEAVE LOOP; END IF;
      
      SET sum_scores = sum_scores + correction_row.score * correction_row.weight;
      SET sum_weights = sum_weights + correction_row.weight;
    END LOOP;
    CLOSE correction_cursor;
    
    -- Update user average score
    IF sum_weights > 0 THEN
      UPDATE users SET average_score = sum_scores / sum_weights WHERE id = user_row.id;
    END IF;
  END LOOP;
  CLOSE user_cursor;
END;
