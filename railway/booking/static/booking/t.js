document.querySelectorAll('.booking-form').forEach(form => {
  	form.querySelectorAll('input[type="radio"][name="class-selection"]').forEach(radio => {
		radio.addEventListener('change', function() {
			const selectedClass = this.value;
			const distance = form.querySelector('.distance-info').innerHTML;
			const price = form.querySelector('.price');
			const priceInfo = form.querySelector('.price-info');

			priceInfo.classList.remove('hide-before');

			// console.log('Selected class:', selectedClass);
			// console.log('Train ID:', trainId);

			const csrfToken = form.querySelector('[name=csrfmiddlewaretoken]').value;

			fetch('/update-price/', {
				method: 'POST',
				headers: {
				'Content-Type': 'application/json',
				'X-CSRFToken': csrfToken
				},
				body: JSON.stringify({
				selected_class: selectedClass,
				distance: distance,
				})
			})
			.then(response => response.json())
			.then(data => {
				// console.log('Server response:', data);
				// console.log(data['price']);
				price.innerHTML=data['price']
			});
		});
	});
});