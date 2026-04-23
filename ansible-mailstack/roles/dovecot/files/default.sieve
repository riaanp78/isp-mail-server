require ["fileinto", "mailbox"];

if header :is "X-Rspamd-Action" "reject" {
    fileinto :create "Junk";
    stop;
}

keep;