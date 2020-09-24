<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
    <#if section = "header">
        ${msg("termsTitle")}
    <#elseif section = "form">
    <div id="kc-terms-text">
        ${kcSanitize(msg("termsText"))?no_esc}
        <ul style="margin-top: 10px;">
            <li><a target="_blank" rel="noopener noreferrer" href="https://wiki.archlinux.org/index.php/Code_of_conduct">Code of Conduct</a></li>
            <li><a target="_blank" rel="noopener noreferrer" href="https://gitlab.archlinux.org/archlinux/service-agreements/-/blob/master/terms-of-service.md">Terms of Service</a></li>
            <li><a target="_blank" rel="noopener noreferrer" href="https://gitlab.archlinux.org/archlinux/service-agreements/-/blob/master/privacy-policy.md">Privacy Policy</a></li>
        </ul>
    </div>
    <form class="form-actions" action="${url.loginAction}" method="POST">
        <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" name="accept" id="kc-accept" type="submit" value="${msg("doAccept")}"/>
        <input class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}" name="cancel" id="kc-decline" type="submit" value="${msg("doDecline")}"/>
    </form>
    <div class="clearfix"></div>
    </#if>
</@layout.registrationLayout>
