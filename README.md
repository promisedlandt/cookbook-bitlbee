# Description

This cookbook helps you manage your [BitlBee](http://bitlbee.org/) installation and configuration, including user accounts and various IM accounts.  

Please read the small section about [passwords](https://github.com/promisedlandt/cookbook-bitlbee#passwords) before starting to use the cookbook.

If you experience any weirdness with accounts not not showing up after adding the to Chef runs after the first Chef run, disconnect from the BitlBee server until the Chef run completes. Restarting the service does not work very well in forked mode.

# Supported accounts

This cookbook does not contain support for all of BitlBee's features.  
Currently supported IM accounts are:

 * ICQ
 * Steam
 * Jabber (XMPP)
 * Facebook - with OAuth or password authentication (you should use OAuth!)
 * HipChat - does not work very well, more details [here](http://wiki.bitlbee.org/HowtoHipchat)
 * Google Talk - the IM part only, not the voice / video part

If you would like to use an IM service that is not listed above, fret not. Simply install BitlBee with this cookbook, then manually add those accounts.

BitlBee also offers a few plugins - the only one supported by this cookbook currently is [Steam messaging](https://github.com/jgeboski/bitlbee-steam).  
OTR plugin support by this cookbook is planned, but might take some time.

# Examples

In all examples we create a BitlBee user "Nils" with password "testpwd".  
This user has an ICQ account, and two jabber accounts.

After running an example, use your favorite IRC client to connect to the bitlbee server, set your nick to "Nils", join "&bitlbee" (if you weren't auto-joined) and type "identify testpwd".  
All the contacts from your ICQ account and two Jabber accounts should now appear as users in the channel (or, if you copy/pasted the examples without setting your own accounts, the accounts will not be able to connect).

## Configuration via node attributes

Configuration via node attributes is simple, but requires a few nested hashes / arrays.  
You also have to specify your cleartext passwords within a role / recipe, which is not ideal.

```ruby
node.set[:bitlbee][:users] = [
  {
    name: "Nils",
    password: "testpwd",
    accounts: {
      icq: [
        {
          handle: "12345678",
          password: "myicqpassword"
        }
      ],
      jabber: [
        {
          handle: "example@jabber.org",
          password: "myjabberpassword"
        },
        {
          handle: "myotheraccount@jabber.ccc.de",
          password: "anotherjabberpassword"
        }
      ]
    }
  }
]

# Install and start bitlbee, create user as stated above
include_recipe "bitlbee::default"
```

## Configuration via LWRPs

If you prefer using LWRPs, this cookbook has you covered:

```ruby
# Install bitlbee, don't set up any users
include_recipe "bitlbee::default"

# Same as the above example, create a bitlbee user account
bitlbee_user_account "Nils" do
  password "testpwd"
end

# create our ICQ account
bitlbee_icq_account "12345678" do
  password "myicqpassword"
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end

bitlbee_jabber_account "example@jabber.org" do
  password "myjabberpassword"
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end

bitlbee_jabber_account "myotheraccount@jabber.ccc.de" do
  password "anotherjabberpassword"
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end
```

# Platforms

Ubuntu and Debian. Check [.kitchen.yml](https://github.com/promisedlandt/cookbook-bitlbee/blob/master/.kitchen.yml) for the exact versions tested.

# Passwords

## Using this cookbook is not safe

BitlBee [hashes the user passwords on disk](http://wiki.bitlbee.org/DecodingPasswords), and encrypts all IM account passwords.  
As this cookbook creates the configuration files internally before writing it to disk, it must use the BitlBee-provided hashing and encryption commands.

**This is achieved by shelling out, meaning your passwords may appear in cleartext in your shell history.**  
I try to prevent this by leading the command with a space, but a shell does not have to respect this.

In other words, if the computer you run BitlBee on is compromised, all your IM accounts can be compromised too.

## Why do I need to enter my cleartext password when creating IM accounts?

Since BitlBee hashes the user password, but needs the cleartext password to encrypt the various IM services' passwords, you need to specify the cleartext user password whenever you create an IM account with an LWRP.  
If you're using node attributes, this cookbook will take care of that for you (assuming the user has a password set).

# Recipes

## bitlbee::default

Installs bitlbee, sets up all specified user / IM accounts.

## bitlbee::docker

Does the same as bitlbee::default recipe, but sets a few a attributes that make sense when you want to build a docker container:

 * `init_style` is set to "none". Start bitlbee with the docker CMD command instead, or explicitly when you start the docker container

# Attributes

All attributes are under the `:bitlbee` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
user | System user all files belong to, and the service runs as | String | bitlbee
group | System group for the above user | String | bitlbee
config_dir | Directory where bitlbee system configuration and motd are stored | String | /etc/bitlbee
data_dir | Directory where bitlbee user xml files are stored | String | /var/lib/bitlbee
port | The bitlbee service will listen on this port | String | 6667
users | Accounts for all BitlBee users and their various IM accounts. See [below](https://github.com/promisedlandt/cookbook-bitlbee#user_account_attributes) | Array<Hash> | []

## User Account Attributes

Probably the easiest way to get your accounts setup is to set the `node[:bitlbee][:users]` attribute, as in the first example.

It is an array of hashes, with each hash being a BitlBee user and that users IM accounts.

At the least, the user needs a name and a cleatext password (for authentication inside the BitlBee control channel), so a minimal example would be:

```ruby
{ name: "testuser",
  password: "testpassword" }
```

Accounts are specified as a hash under the ":accounts" key.  
In the accounts hash, the key is the name of the protocol, the value an array of hashes with the actual account information.  
Accounts typically need a handle (the username) and a password (in cleartext), like so:

```ruby
{ name: "testuser",
  password: "testpassword",
  accounts: {
    icq: [
      { handle: "1234567890",
        password: "qwer" },
      { handle: "44444444",
        password: "asdf" }
    ]
  } 
}
```

Supported protocols are: `:icq, :jabber, :facebook, :gtalk, :steam, :hipchat`.

Facebook and GTalk default to using OAuth - simply don't set a password for them.

```ruby
{ name: "testuser",
  password: "testpassword",
  accounts: {
    facebook: [
      { handle: "facebook.user" }
    ],
    gtalk: [
      { handle: "test@googlemail.com" }
    ]
  } 
}
```

If you run into any trouble, refer to the LWRPs below - their attributes are the same keys you can set in this hash.

# BitlBee system configuration file

BitlBee uses a well documented configuration file under `/etc/bitlbee/bitlbee.conf` (by default).  
This cookbook does not currently offer any ways to provision this file.

# Resources / Providers

This cookbook offers numerous LWRPs to manage your bitlbee user and IM accounts.

## bitlbee_user_account

A BitlBee user account, like using `register <password>`.

### Actions

Name | Description | default?
-----|-------------|---------
create_or_modify | Creates the account, or modifies it if it already exists | default
delete | Delete this account |

### Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
username | Username for this account, what your IRC nick needs to be set to | String | name
password | Cleartext password for this user | String | 

### Examples

```ruby
bitlbee_user_account "Nils" do
  password "testpwd"
end
```

## bitlbee_icq_account

An account with the ICQ IM service, belonging to a user

### Actions

Name | Description | default?
-----|-------------|---------
create_or_modify | Creates the account, or modifies it if it already exists | default
remove | Remove this account |

### Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
handle | Your ICQ number | String | name
password | Cleartext password for your ICQ account | String | 
user | Username of the BitlBee user account the ICQ account belongs to | String | 
user_cleartext_password | Cleartext password of the user account | String | 

### Examples

```ruby
bitlbee_icq_account "12345678" do
  password "myicqpassword"
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end
```

## bitlbee_jabber_account

An account with a Jabber IM service, belonging to a user

### Actions

Name | Description | default?
-----|-------------|---------
create_or_modify | Creates the account, or modifies it if it already exists | default
remove | Remove this account |

### Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
handle | Your JID + server. Do not specify resource here! | String | name
password | Cleartext password for your Jabber account | String | 
user | Username of the BitlBee user account the Jabber account belongs to | String | 
user_cleartext_password | Cleartext password of the user account | String | 

### Examples

```ruby
bitlbee_jabber_account "example@jabber.org" do
  password "myjabberpassword"
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end
```

## bitlbee_hipchat_account

An account with [HipChat](https://hipchat.com). 
Get your login name [here](https://www.hipchat.com/account/xmpp).

There are issues with BitlBee and HipChat, see [here](http://wiki.bitlbee.org/HowtoHipchat) for the BitlBee side of things.

From the [HipChat Knowledge Base](http://help.hipchat.com/knowledgebase/articles/64439-how-to-connect-using-pidgin):
> **Warning**: If you choose to use non-HipChat client you will miss out on some of or best features: file sharing, @mentions, inline previews for images, YouTube videos, Tweets, etc, audio/video chat, and room creation/management. 

### Actions

Name | Description | default?
-----|-------------|---------
create_or_modify | Creates the account, or modifies it if it already exists | default
remove | Remove this account |

### Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
handle | Your HipChat username or Jabber ID from [this page](https://www.hipchat.com/account/xmpp) | String | name
password | Cleartext password for your HipChat account | String | 
user | Username of the BitlBee user account the HipChat account belongs to | String | 
user_cleartext_password | Cleartext password of the user account | String | 

### Examples

```ruby
bitlbee_hipchat_account "12345_67890123" do
  password "myhipchatpwd"
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end
```

## bitlbee_facebook_account

An account with Facebook.

There are [some issues](http://wiki.bitlbee.org/HowtoFacebook#Lost_messages), but it works okay.

You can either authenticate using your Facebook password, or via OAuth, limiting exposure in case BitlBee / this cookbook leaks your password.

If you decide to use OAuth (which I suggest), you will get a query with a link to click once you connect & identify in BitlBee. Just follow instructions.

Once everything works, you will get a message like "Server claims your JID is '-12345678@chat.facebook.com' instead of '<username you actually entered>'. This mismatch may cause problems with groupchats and possibly other things.".  

Create a new account with handle set to "-12345678@chat.facebook.com" (or whatever the server sent), and everything will be fine.   
At some point, a way to rename accounts will be added to this cookbook.

Instructions taken from [here](http://wiki.bitlbee.org/HowtoFacebook).

### Actions

Name | Description | default?
-----|-------------|---------
create_or_modify | Creates the account, or modifies it if it already exists | default
remove | Remove this account |

### Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
handle | Your Facebook username, get it [here](http://www.facebook.com/username/), or your Facebook JID once you know it | String | name
auth_strategy | How to authenticate to Facebook. OAuth is preferred, but password is easier to setup | [:oauth, :password] | :oauth
password | Don't set when using OAuth! Cleartext password for your Facebook account | String | 
user | Username of the BitlBee user account the Steam account belongs to | String | 
user_cleartext_password | Cleartext password of the user account | String | 

### Examples

```ruby
# using OAuth (and you should!)
bitlbee_facebook_account "nils.landt" do
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end

# using password
bitlbee_facebook_account "nils.landt" do
  auth_strategy :password
  password "myfacebookpassword"
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end
```

## bitlbee_steam_account

An account with a Valves [Steam](http://store.steampowered.com/) platform, belonging to a user.  

Note that you will have to manually authenticate with SteamGuard, which possibly includes solving a captcha.  
The root user in your &bitlbee channel will walk you through the process, so will the plugins [readme](https://github.com/jgeboski/bitlbee-steam).

You will need to install the bitlbee_steam_plugin.

### Actions

Name | Description | default?
-----|-------------|---------
create_or_modify | Creates the account, or modifies it if it already exists | default
remove | Remove this account |

### Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
handle | Your Steam login name | String | name
password | Cleartext password for your Steam account | String | 
user | Username of the BitlBee user account the Steam account belongs to | String | 
user_cleartext_password | Cleartext password of the user account | String | 

### Examples

```ruby
bitlbee_steam_account "mysteamusername" do
  password "mysteampassword"
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end
```

## bitlbee_gtalk_account

Google Talk, the IM part anyway.

You can either use your "@googlemail.com" / "@gmail.com" email address, or the email address of your Google Apps account.

Only OAuth is provided by this cookbook.  
On first identify, you will get a query window from the root user, asking you to click a link and reply with the auth token.

### Actions

Name | Description | default?
-----|-------------|---------
create_or_modify | Creates the account, or modifies it if it already exists | default
remove | Remove this account |

### Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
handle | Your GMail address, or Google Apps email address | String | name
user | Username of the BitlBee user account the GMail account belongs to | String | 
user_cleartext_password | Cleartext password of the user account | String | 

### Examples

```ruby
bitlbee_gtalk_account "example@googlemail.com" do
  user "Nils"
  user_cleartext_password "testpwd"   # See [here](https://github.com/promisedlandt/cookbook-bitlbee#passwords) why this is needed
end
```

## bitlbee_steam_plugin

The [steam plugin](https://github.com/jgeboski/bitlbee-steam) to allow connecting to the Steam network.

### Actions

Name | Description | default?
-----|-------------|---------
install | Installs the plugin | default

### Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
name | Write anything here. Chef resource must have a name | String | name

### Examples

```ruby
bitlbee_steam_plugin "bitlbee_steam_plugin"
```
