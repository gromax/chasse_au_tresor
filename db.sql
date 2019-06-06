-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Client :  localhost:3306
-- Généré le :  Jeu 06 Juin 2019 à 14:23
-- Version du serveur :  10.1.40-MariaDB-0ubuntu0.18.04.1
-- Version de PHP :  7.2.17-0ubuntu0.18.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données :  `chasseautresor`
--

-- --------------------------------------------------------

--
-- Structure de la table `essaisJoueur`
--

CREATE TABLE `essaisJoueur` (
  `id` int(11) NOT NULL,
  `idPartie` int(11) NOT NULL,
  `essai` text CHARACTER SET utf8 NOT NULL,
  `data` text CHARACTER SET utf8 NOT NULL,
  `date` datetime NOT NULL,
  `idItem` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `evenements`
--

CREATE TABLE `evenements` (
  `id` int(11) NOT NULL,
  `idProprietaire` int(11) NOT NULL,
  `titre` text CHARACTER SET utf8 NOT NULL,
  `description` text CHARACTER SET utf8 NOT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `visible` tinyint(1) NOT NULL,
  `hash` text CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `hashs`
--

CREATE TABLE `hashs` (
  `id` int(11) NOT NULL,
  `type` tinyint(4) NOT NULL,
  `hash` text CHARACTER SET utf8 NOT NULL,
  `idProprietaire` int(11) NOT NULL,
  `idCible` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `images`
--

CREATE TABLE `images` (
  `id` int(11) NOT NULL,
  `idEvenement` int(11) NOT NULL,
  `hash` varchar(50) CHARACTER SET utf8 NOT NULL,
  `ext` varchar(4) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `itemsEvenement`
--

CREATE TABLE `itemsEvenement` (
  `id` int(11) NOT NULL,
  `idEvenement` int(11) NOT NULL,
  `subItemsData` text CHARACTER SET utf8 NOT NULL,
  `tagCle` text CHARACTER SET utf8 NOT NULL,
  `regexCle` text CHARACTER SET utf8 NOT NULL,
  `pts` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `joueurs`
--

CREATE TABLE `joueurs` (
  `id` int(11) NOT NULL,
  `nom` text CHARACTER SET utf8 NOT NULL,
  `username` text CHARACTER SET utf8 NOT NULL,
  `hash` varchar(60) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `parties`
--

CREATE TABLE `parties` (
  `id` int(11) NOT NULL,
  `idEvenement` int(11) NOT NULL,
  `idProprietaire` int(11) NOT NULL,
  `dateDebut` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `redacteurs`
--

CREATE TABLE `redacteurs` (
  `id` int(11) NOT NULL,
  `nom` text CHARACTER SET utf8 NOT NULL,
  `username` text CHARACTER SET utf8 NOT NULL,
  `hash` varchar(60) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Index pour les tables exportées
--

--
-- Index pour la table `essaisJoueur`
--
ALTER TABLE `essaisJoueur`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `evenements`
--
ALTER TABLE `evenements`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `hashs`
--
ALTER TABLE `hashs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `images`
--
ALTER TABLE `images`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `itemsEvenement`
--
ALTER TABLE `itemsEvenement`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `joueurs`
--
ALTER TABLE `joueurs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `parties`
--
ALTER TABLE `parties`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `redacteurs`
--
ALTER TABLE `redacteurs`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables exportées
--

--
-- AUTO_INCREMENT pour la table `essaisJoueur`
--
ALTER TABLE `essaisJoueur`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `evenements`
--
ALTER TABLE `evenements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `hashs`
--
ALTER TABLE `hashs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `images`
--
ALTER TABLE `images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `itemsEvenement`
--
ALTER TABLE `itemsEvenement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `joueurs`
--
ALTER TABLE `joueurs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `parties`
--
ALTER TABLE `parties`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `redacteurs`
--
ALTER TABLE `redacteurs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
