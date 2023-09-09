// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/src/models/user.rs
//
// Summary: User model.

use chrono::Datelike;
use lazy_static::lazy_static;
use regex::Regex;
use serde::{Deserialize, Serialize};
use validator::{Validate, ValidationError};

lazy_static! {
    static ref ISO_8601_DATE: Regex = Regex::new(r"^\d{4}-\d{2}-\d{2}$").unwrap();
}

#[derive(Clone, Debug, Deserialize, Serialize, Validate)]
#[serde(rename_all = "camelCase")]
pub struct User {
    #[validate(regex = "ISO_8601_DATE")]
    #[validate(custom = "validate_date_of_birth")]
    pub date_of_birth: String,

    #[serde(skip_serializing_if = "Option::is_none")]
    #[validate(custom = "validate_username")]
    pub username: Option<String>,
}

fn validate_date_of_birth(date_of_birth: &str) -> Result<(), ValidationError> {
    let parsed_date = chrono::naive::NaiveDate::parse_from_str(date_of_birth, "%F");
    if parsed_date.is_ok() && parsed_date.unwrap() < chrono::Utc::now().date_naive() {
        return Ok(());
    }
    Err(ValidationError::new(
        "Date of birth should have the format YYYY-MM-DD and be in the past",
    ))
}

fn validate_username(username: &str) -> Result<(), ValidationError> {
    if username.chars().all(char::is_alphabetic) && !username.is_empty() {
        return Ok(());
    }
    Err(ValidationError::new(
        "The username should only contain alphabetic characters",
    ))
}

impl User {
    pub fn days_till_birthday(&self) -> i64 {
        let date_of_birth =
            chrono::naive::NaiveDate::parse_from_str(&self.date_of_birth, "%F").unwrap();

        let today = chrono::Utc::now().date_naive();

        let birthday_this_year = chrono::naive::NaiveDate::from_ymd_opt(
            today.year(),
            date_of_birth.month(),
            date_of_birth.day(),
        )
        .unwrap();

        if birthday_this_year < today {
            let birthday_next_year = chrono::naive::NaiveDate::from_ymd_opt(
                today.year() + 1,
                date_of_birth.month(),
                date_of_birth.day(),
            )
            .unwrap();
            dbg!((birthday_next_year - today).num_days());
            return (birthday_next_year - today).num_days();
        }
        (birthday_this_year - today).num_days()
    }
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
