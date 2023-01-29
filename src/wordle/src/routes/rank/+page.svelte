<script lang="ts">
	export let data: {ranking: [ {name: string; score: number} ]};
	const rank = data.ranking;
</script>

<svelte:head>
	<title>Ranking</title>
	<meta name="description" content="Ranking this game" />
</svelte:head>

<div class="text-column">
	<table width=300 height="100%" >
		<th>Rank</th>
		<th>User</th>
		<th>Score</th>
		{#each Array(5) as _, row}
			{@const name = rank[row]?.name}
			{@const score = rank[row]?.score}
			<tr class="table">
				<td>{row+1}.</td>
				<td id="name1">{name}</td>
				<td id="score1">{score}</td>
			</tr>
		{:else}
		<h1> loading...</h1>
		{/each}

		<tr class="table" id="you">
		</tr>
	</table>
</div>

<style>
	.table{
		text-align: center;
		border: 10px;
	}
</style>