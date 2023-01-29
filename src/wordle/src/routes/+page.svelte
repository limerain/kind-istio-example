<script lang="ts">
	import wordle from '$lib/images/wordle.webp';
	import wordle_fallback from '$lib/images/wordle.png';
	import { browser } from '$app/environment'
	import axios from 'axios';

	if(browser){
		const clicker = async () => {
			const userName: string = (document.getElementById('name')! as HTMLInputElement).value;
			const sendData = {
				name: userName
			};
			const result = await axios.post(`http://localhost:5173/user/`, sendData);
			location.href = `/sverdle?Id=${result.data.id}`;
		};
		document.getElementById('EnterButton')?.addEventListener('click', clicker);
	}
</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<section>
	<h1>
		<span class="welcome">
			<picture>
				<source srcset={wordle} type="image/webp" />
				<img src={wordle_fallback} alt="Wordle" />
			</picture>
		</span>
	</h1>

	<label for="name">Enter Your Name:</label>
	<input type="text" id="name" name="name" size="10">
	<button type="button" id="EnterButton" >
    Join
	</button>

	<!-- <Counter /> -->
</section>

<style>
	section {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		flex: 0.6;
	}

	h1 {
		width: 100%;
	}

	.welcome {
		display: block;
		margin:auto;
		position: relative;
		width: 50%;
		height: 100%;
		padding: 0 0 calc(100% * 495 / 2048) 0;
	}

	.welcome img {
		position: absolute;
		width: 100%;
		top: 0;
		display: block;
		text-align: center;
	}
</style>
