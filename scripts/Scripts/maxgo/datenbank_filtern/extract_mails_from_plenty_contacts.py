import pandas as pd

INPUT = "data.csv"
OUTPUT_ALL = "data_with_email_export_flag.csv"
OUTPUT_EXPORT = "email_export_rows.csv"

email_columns = [
    "ContactOption.emailPrivate",
    "ContactOption.emailWork",
    "DeliveryAddressOption.email",
]

blocked_strings = [
    "amazon.de",
    "amazon.com",
    "amazon.com.be",
    "amazon.nl",
    "amazon.it",
    "amazon.ie",
    "amazon.be",
    "amazon.pl",
    "amazon.es",
    "amazon.se",
    "ebay.com",
    "kaufland-online.com",
    "kaufland-online.de",
]

def clean_email(v) -> str:
    # Return a real lowercase email string or "" if missing/invalid
    if v is None or (isinstance(v, float) and pd.isna(v)):
        return ""
    s = str(v).strip()
    if not s or s.lower() == "nan" or s == "None":
        return ""
    return s.lower()

def has_allowed_email(row) -> bool:
    for col in email_columns:
        email = clean_email(row.get(col, ""))
        if email and not any(bad in email for bad in blocked_strings):
            return True
    return False

def first_allowed_email(row) -> str:
    for col in email_columns:
        email = clean_email(row.get(col, ""))
        if email and not any(bad in email for bad in blocked_strings):
            return email
    return ""

# Read CSV with semicolon separator
df = pd.read_csv(INPUT, sep=";", dtype=object)  # keep raw values, including NaN

# Ensure missing email columns exist
for col in email_columns:
    if col not in df.columns:
        df[col] = ""

# Compute flags
df["email-export"] = df.apply(lambda r: "x" if has_allowed_email(r) else "", axis=1)

# Extract first usable email (blank if none)
df["email-first-allowed"] = df.apply(first_allowed_email, axis=1)

# Save using semicolon
df.to_csv(OUTPUT_ALL, sep=";", index=False)
df[df["email-export"] == "x"].to_csv(OUTPUT_EXPORT, sep=";", index=False)

