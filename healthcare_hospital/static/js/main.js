document.addEventListener("DOMContentLoaded", () => {
    // Automatically dismiss Bootstrap alerts after 6 seconds.
    document.querySelectorAll(".alert.alert-dismissible").forEach((alert) => {
        window.setTimeout(() => {
            const instance = bootstrap.Alert.getOrCreateInstance(alert);
            instance.close();
        }, 6000);
    });

    // Department -> doctor filtering helper on appointment forms.
    const department = document.getElementById("id_department");
    const doctor = document.getElementById("id_doctor");
    if (department && doctor) {
        department.addEventListener("change", () => {
            // Kept intentionally simple so developers can replace this with
            // a Django JSON endpoint/AJAX call without changing the template.
            doctor.dataset.department = department.value;
        });
    }
});
