class User < ActiveRecord::Base

	#####################
    ### Relationships ###
    #####################
    has_many :ratings
    has_many :movies, :through => :ratings

	##################
    ### Encription ###
    ##################
	attr_accessor :password, :password_confirmation
	before_save :encryptPassword

	##################
    ### Validation ###
    ##################
	validates_confirmation_of :password
	validates_presence_of :password, :on => :create
	validates_presence_of :loginUsername
	validates_uniqueness_of :loginUsername

	before_create { generateToken(:loginAuthToken) }
  
  	###############
    ### Methods ###
    ###############

	def authenticate(name, password)
	  	user = User.find_by loginUsername: name
	  	if user && user.loginPasswordHash == BCrypt::Engine.hash_secret(password, user.loginPasswordSalt)
	  	  	return user
	  	else
	  	  	return nil
	  	end
	end # authenticate
  
	def encryptPassword
	  if password.present?
	    	self.loginPasswordSalt = BCrypt::Engine.generate_salt
	    	self.loginPasswordHash = BCrypt::Engine.hash_secret(password, loginPasswordSalt)
	  end
	end # encryptPassword

  	def generateToken(column)
	  	begin
	    	self[column] = SecureRandom.urlsafe_base64
	  	end while User.exists?(column => self[column])
	end # generateToken

	def screenName
		if self.useNickname == true && self.nameNickname != nil && self.nameNickname.length != 0
			return self.nameNickname
		else
			return self.nameFirst + " " + self.nameLast
		end
		return "-NoNameError-"
	end # screenName

	def gravatarUrl(size=20)
  		if (self.contactEmail == nil || self.contactEmail.length < 5); return nil; end;
  	  	gravatar_id = Digest::MD5.hexdigest(self.contactEmail.downcase)
  	  	return "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  	end # gravatarUrl

  	def avatar(size=20)
  		image = "<img src=\""+self.gravatarUrl(size)+"\" class=\"img-circle\" style=\"width:"+size.to_s+"px; height:"+size.to_s+"px;\" />"
  		name = self.screenName
  		return image.html_safe + " " + name
  	end # avatar
end
