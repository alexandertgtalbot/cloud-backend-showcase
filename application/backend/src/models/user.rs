// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/src/models/user.rs
//
// Summary: User model.

use serde::{Deserialize, Serialize};
use validator::Validate;

#[derive(Clone, Debug, Deserialize, Serialize, Validate)]
#[serde(rename_all = "camelCase")]
pub struct User {
    pub date_of_birth: String,
    pub username: Option<String>,
}

#[cfg(test)]
mod validation {
    use super::*;

    #[test]
    fn accept_iso_8601_compliant_date_in_the_past() {
        let user = User {
            date_of_birth: String::from("2023-09-05"),
            username: None,
        };
        assert!(user.validate().is_ok());
    }

    #[test]
    fn reject_iso_8601_compliant_date_for_today() {
        let user = User {
            date_of_birth: chrono::Utc::now().date_naive().to_string(),
            username: None,
        };
        assert!(user.validate().is_err());
    }

    #[test]
    fn reject_single_digit_month_and_day() {
        let user = User {
            date_of_birth: String::from("2023-9-6"),
            username: None,
        };
        assert!(user.validate().is_err());
    }

    #[test]
    fn reject_freedom_format() {
        let user = User {
            date_of_birth: String::from("09-06-2023"),
            username: None,
        };
        assert!(user.validate().is_err());
    }

    #[test]
    fn accept_valid_username() {
        let user = User {
            date_of_birth: String::from("2023-09-05"),
            username: Some(String::from("test")),
        };
        assert!(user.validate().is_ok());
    }

    #[test]
    fn reject_username_with_digits() {
        let user = User {
            date_of_birth: String::from("2023-09-05"),
            username: Some(String::from("test123")),
        };
        assert!(user.validate().is_err());
    }

    #[test]
    fn reject_username_with_special_characters() {
        let user = User {
            date_of_birth: String::from("2023-09-05"),
            username: Some(String::from("test!")),
        };
        assert!(user.validate().is_err());
    }

    #[test]
    fn reject_username_of_zero_legth() {
        let user = User {
            date_of_birth: String::from("2023-09-05"),
            username: Some(String::from("")),
        };
        assert!(user.validate().is_err());
    }
}
