CREATE PROCEDURE ComputeAverageWeightedScoreForUser(IN user_id INT)
BEGIN
  DECLARE sum_scores DECIMAL(10,2) DEFAULT 0;
  DECLARE sum_weights INT DEFAULT 0;
  
  -- Check if user exists
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = user_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not exist';
    RETURN;
  END IF;
  
  -- Calculate sum of scores and weights for the user
  SET sum_scores = 0;
  SET sum_weights = 0;
  
  SELECT SUM(score * weight) AS total_weighted_score, SUM(weight) AS total_weight
  FROM corrections c
  INNER JOIN projects p ON c.project_id = p.id
  WHERE c.user_id = user_id;
  
  -- Update user average score if corrections exist
  IF total_weight > 0 THEN
    SET sum_scores = total_weighted_score;
    SET sum_weights = total_weight;
    
    UPDATE users SET average_score = sum_scores / sum_weights WHERE id = user_id;
  END IF;
END;
