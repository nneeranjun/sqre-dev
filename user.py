class User:
    def __init__(self, name, email, phone_number, facebook, user_id):
        self.name = name
        self.email = email
        self.phone_number = phone_number
        self.facebook = facebook
        self.user_id = user_id
    def __init__(self, name, email, phone_number, socials):
        self.name = name
        self.email = email
        self.phone_number = phone_number
        self.socials = socials
    def get_social(name):
        if name not in self.socials:
            return -1
        else:
            return self.socials[name]
    
    def __str__(self):
        return "" + self.name + " " + self.email + " " + self.phone_number
    def serialize(self):
        return {
            "name": self.name,
            "email": self.email,
            "phone_number": self.phone_number,
            "facebook": facebook,
            "user_id": self.user_id
        }
