// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/src/models/user.rs
//
// Summary: User model.

use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct User {
    pub date_of_birth: String,
    pub username: Option<String>,
}
