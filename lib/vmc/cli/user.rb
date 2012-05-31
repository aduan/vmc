require "vmc/cli/command"

module VMC
  class User < Command
    desc "create [EMAIL]", "Create a user"
    group :admin, :user, :hidden => true
    flag(:email) {
      ask("Email")
    }
    flag(:password) {
      ask("Password", :echo => "*", :forget => true)
    }
    flag(:verify) {
      ask("Verify Password", :echo => "*", :forget => true)
    }
    def create(email = nil)
      email ||= input(:email)
      password = input(:password)

      if !force? && password != input(:verify)
        fail "Passwords don't match."
      end

      with_progress("Creating user") do
        client.register(email, password)
      end
    end

    desc "delete [EMAIL]", "Delete a user"
    group :admin, :user, :hidden => true
    flag(:really) { |email|
      force? || ask("Really delete user #{c(email, :blue)}?", :default => false)
    }
    def delete(email)
      return unless input(:really, email)

      with_progress("Deleting #{c(email, :blue)}") do
        client.user(email).delete!
      end
    ensure
      forget(:really)
    end

    desc "passwd [EMAIL]", "Update a user's password"
    group :admin, :user, :hidden => true
    flag(:email) {
      ask("Email")
    }
    flag(:password) {
      ask("Password", :echo => "*", :forget => true)
    }
    flag(:verify) {
      ask("Verify Password", :echo => "*", :forget => true)
    }
    def passwd(email = nil)
      email ||= input(:email)
      password = input(:password)
      verify = input(:verify)

      if password != verify
        fail "Passwords don't match."
      end

      with_progress("Changing password") do
        user = client.user(email)
        user.password = password
        user.update!
      end
    end
  end
end