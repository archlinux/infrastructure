require ["mailbox", "fileinto"];
if header "X-Spam" "Yes"{
  fileinto :create "Junk";
  stop;
}
