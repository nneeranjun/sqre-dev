class User:
    def __init__(self, name, email, phone_number, user_id):
        self.name = name
        self.email = email
        self.phone_number = phone_number
        self.user_id = user_id
    def __str__(self):
        return "" + self.name + " " + self.email + " " + self.phone_number
    def serialize(self):
        return {
            "name": self.name,
            "email": self.email,
            "phone_number": self.phone_number,
            "user_id": self.user_id
        }