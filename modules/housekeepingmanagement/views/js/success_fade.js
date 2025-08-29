document.addEventListener('DOMContentLoaded', function() {
    setTimeout(function() {
        var alertBox = document.querySelector('.alert-success');
        if (alertBox) {
            alertBox.style.transition = 'opacity 0.5s ease';
            alertBox.style.opacity = '0';
            setTimeout(function() { alertBox.remove(); }, 500);
        }
    }, 10000);

    if (window.history.replaceState) {
        var url = new URL(window.location.href);
        url.searchParams.delete('conf');
        window.history.replaceState({}, document.title, url.toString());
    }
});
